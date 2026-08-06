# Data Models

## Learner
- id
- displayName
- ageBand
- role
- currentPathwayIds
- completedLessonIds
- skillIds
- badgeIds
- reflectionIds
- guardianModeEnabled
- createdAt
- updatedAt

## Pathway
- id
- title
- description
- level
- estimatedHours
- unitIds
- skillIds
- projectIds
- tags

## Unit
- id
- pathwayId
- title
- order
- lessonIds
- assessmentIds

## Lesson
- id
- unitId
- title
- summary
- contentMarkdown
- durationMinutes
- activitySteps
- quizIds
- reflectionPrompts
- requiredMaterials
- safetyNotes
- skillIds

## Project
- id
- title
- brief
- materials
- tools
- steps
- evidenceRequirements
- safetyChecklist
- linkedLessons

## Skill
- id
- name
- category
- level
- evidenceRequired

## Badge
- id
- title
- description
- criteria
- skillIds

## Reflection
- id
- learnerId
- lessonId
- prompt
- response
- mood
- createdAt

## Assessment
- id
- type
- title
- questions
- practicalChecklist
- passCriteria

## MentorNote
- id
- learnerId
- author
- note
- visibility
- createdAt
