import { FinanceInputs, FinanceResult } from './launchpad_models';

export function calculateCampaignFinance(input: FinanceInputs): FinanceResult {
  const grossFundingGbp = input.fundingGoalGbp;
  const platformFeesGbp = grossFundingGbp * (input.kickstarterFeePercent / 100);
  const paymentFeesGbp = grossFundingGbp * (input.paymentFeePercent / 100);
  const taxReserveGbp = grossFundingGbp * (input.taxReservePercent / 100);
  const contingencyReserveGbp = grossFundingGbp * (input.contingencyPercent / 100);

  const usableBuildFundsGbp =
    grossFundingGbp -
    platformFeesGbp -
    paymentFeesGbp -
    taxReserveGbp -
    contingencyReserveGbp -
    input.fixedCostsGbp -
    input.rewardDeliveryCostsGbp;

  return {
    grossFundingGbp,
    platformFeesGbp,
    paymentFeesGbp,
    taxReserveGbp,
    contingencyReserveGbp,
    usableBuildFundsGbp,
  };
}

export const microGrowExampleFinance: FinanceInputs = {
  fundingGoalGbp: 35000,
  kickstarterFeePercent: 5,
  paymentFeePercent: 3,
  taxReservePercent: 10,
  contingencyPercent: 12,
  fixedCostsGbp: 15000,
  rewardDeliveryCostsGbp: 7000,
};
