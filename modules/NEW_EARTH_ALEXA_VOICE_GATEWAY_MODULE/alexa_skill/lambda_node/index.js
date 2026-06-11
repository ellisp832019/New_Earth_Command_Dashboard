const Alexa = require('ask-sdk-core');

const GATEWAY_URL = process.env.NEW_EARTH_GATEWAY_URL || 'https://example.com/voice/command';
const GATEWAY_SECRET = process.env.NEW_EARTH_VOICE_GATEWAY_SECRET || '';

const intentToCommand = {
  GetTodaySummaryIntent: 'dashboard.summary.today',
  GetProjectStatusIntent: 'dashboard.project.status.read',
  GetMicroGrowStatusIntent: 'microgrow.status.read',
  AddDashboardNoteIntent: 'dashboard.note.add',
  AddTaskIntent: 'dashboard.task.add',
  StartFocusModeIntent: 'dashboard.focus.start',
  ListNextTasksIntent: 'dashboard.tasks.next',
  GatewayHealthIntent: 'gateway.health.read'
};

function getSlotValue(handlerInput, slotName) {
  const slots = handlerInput.requestEnvelope.request.intent.slots || {};
  const slot = slots[slotName];
  return slot && slot.value ? slot.value : undefined;
}

async function sendToGateway(handlerInput, command) {
  const intentName = handlerInput.requestEnvelope.request.intent.name;
  const sessionId = handlerInput.requestEnvelope.session && handlerInput.requestEnvelope.session.sessionId;
  const slots = {};

  const note = getSlotValue(handlerInput, 'note');
  const task = getSlotValue(handlerInput, 'task');
  if (note) slots.note = note;
  if (task) slots.task = task;

  const response = await fetch(GATEWAY_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Gateway-Secret': GATEWAY_SECRET
    },
    body: JSON.stringify({
      source: 'alexa',
      intent: intentName,
      command,
      slots,
      session_id: sessionId
    })
  });

  if (!response.ok) {
    throw new Error(`Gateway returned HTTP ${response.status}`);
  }

  return response.json();
}

const LaunchRequestHandler = {
  canHandle(handlerInput) {
    return Alexa.getRequestType(handlerInput.requestEnvelope) === 'LaunchRequest';
  },
  handle(handlerInput) {
    const speakOutput = 'New Earth Dashboard voice gateway is ready. You can ask for your summary, project status, MicroGrow status, next tasks, or start focus mode.';
    return handlerInput.responseBuilder.speak(speakOutput).reprompt(speakOutput).getResponse();
  }
};

const GatewayIntentHandler = {
  canHandle(handlerInput) {
    return Alexa.getRequestType(handlerInput.requestEnvelope) === 'IntentRequest' &&
      Object.prototype.hasOwnProperty.call(intentToCommand, Alexa.getIntentName(handlerInput.requestEnvelope));
  },
  async handle(handlerInput) {
    const intentName = Alexa.getIntentName(handlerInput.requestEnvelope);
    const command = intentToCommand[intentName];
    try {
      const result = await sendToGateway(handlerInput, command);
      return handlerInput.responseBuilder.speak(result.speech || 'Command complete.').getResponse();
    } catch (error) {
      console.log('Gateway error:', error);
      return handlerInput.responseBuilder
        .speak('I could not reach the New Earth voice gateway safely.')
        .getResponse();
    }
  }
};

const HelpIntentHandler = {
  canHandle(handlerInput) {
    return Alexa.getRequestType(handlerInput.requestEnvelope) === 'IntentRequest' &&
      Alexa.getIntentName(handlerInput.requestEnvelope) === 'AMAZON.HelpIntent';
  },
  handle(handlerInput) {
    const speakOutput = 'You can ask New Earth Dashboard for your summary, project status, MicroGrow status, next tasks, or to add a task.';
    return handlerInput.responseBuilder.speak(speakOutput).reprompt(speakOutput).getResponse();
  }
};

const CancelAndStopIntentHandler = {
  canHandle(handlerInput) {
    return Alexa.getRequestType(handlerInput.requestEnvelope) === 'IntentRequest' &&
      ['AMAZON.CancelIntent', 'AMAZON.StopIntent'].includes(Alexa.getIntentName(handlerInput.requestEnvelope));
  },
  handle(handlerInput) {
    return handlerInput.responseBuilder.speak('Voice gateway closed.').getResponse();
  }
};

const ErrorHandler = {
  canHandle() {
    return true;
  },
  handle(handlerInput, error) {
    console.log(`Error handled: ${error.message}`);
    return handlerInput.responseBuilder
      .speak('The New Earth voice gateway had a problem handling that request.')
      .getResponse();
  }
};

exports.handler = Alexa.SkillBuilders.custom()
  .addRequestHandlers(
    LaunchRequestHandler,
    GatewayIntentHandler,
    HelpIntentHandler,
    CancelAndStopIntentHandler
  )
  .addErrorHandlers(ErrorHandler)
  .lambda();
