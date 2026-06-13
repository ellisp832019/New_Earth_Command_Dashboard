# FSD - Funding & Grants Command Centre

## 1. Purpose

Create a dashboard module that tracks grant applications from idea through research, drafting, submission, decision, reporting and closure.

## 2. Users

Primary user:

- Peter Ellis

Future users:

- project partners
- grant writers
- finance/admin helpers
- delivery managers

## 3. Source of truth

Omega OS path:

```text
D:\NEW_EARTH_OMEGA_OS_PACK\17_FINANCE_AND_TREASURY\09_GRANTS_DONATIONS_AND_FUNDING
```

## 4. Functional requirements

### FR-001 Grant cards

The dashboard shall show grants as cards.

Each card must show:

- grant name
- project
- funding body
- amount requested
- status
- deadline
- priority
- next action
- readiness score
- risk level

### FR-002 Pipeline view

The dashboard shall group cards by status.

### FR-003 Grant detail view

The user shall be able to open a grant and see all details.

### FR-004 Add grant

The user shall be able to create a new grant record.

### FR-005 Edit grant

The user shall be able to edit status, deadline, amount, notes and next action.

### FR-006 Omega folder link

Each grant shall store a folder path.

### FR-007 Readiness score

Each grant shall calculate a total out of 70.

### FR-008 Funding totals

The dashboard shall calculate:

- total requested
- total submitted
- total approved
- total rejected
- total pending

### FR-009 Deadline view

The dashboard shall show upcoming deadlines.

### FR-010 Evidence checklist

The dashboard shall show missing evidence.

## 5. Non-functional requirements

- local-first
- file-based
- human-readable records
- simple JSON/CSV storage
- no cloud dependency
- future AI-ready
- future calendar-ready
- future email-ready

## 6. Screens

1. Grant Pipeline View
2. Grant Detail View
3. Grant Add/Edit Form
4. Deadline View
5. Evidence Library View
6. Partner Support View
7. Reporting and Claims View
8. Funding Analytics View

## 7. Implementation notes

Start with JSON only. Add CSV export/import after the basic flow works.
