export type CampaignStatus =
  | 'Idea'
  | 'Research'
  | 'Prototype'
  | 'Pre-Launch'
  | 'Live'
  | 'Funded'
  | 'Manufacturing'
  | 'Fulfilment'
  | 'Complete'
  | 'Archived';

export interface Campaign {
  id: string;
  name: string;
  project: string;
  type: 'kickstarter' | 'indiegogo' | 'grant' | 'investor' | 'pilot' | 'other';
  status: CampaignStatus;
  funding_goal_gbp: number;
  launch_date?: string | null;
  owner: string;
  summary: string;
  created_at: string;
}

export interface RewardTier {
  id: string;
  name: string;
  price_gbp: number;
  quantity_limit?: number | null;
  estimated_cogs_gbp: number;
  estimated_shipping_gbp: number;
  notes: string;
}

export interface ReadinessItem {
  category: string;
  title: string;
  status: 'Todo' | 'Draft' | 'In Progress' | 'Done' | 'Blocked';
  notes: string;
}

export interface FinanceInputs {
  fundingGoalGbp: number;
  kickstarterFeePercent: number;
  paymentFeePercent: number;
  taxReservePercent: number;
  contingencyPercent: number;
  fixedCostsGbp: number;
  rewardDeliveryCostsGbp: number;
}

export interface FinanceResult {
  grossFundingGbp: number;
  platformFeesGbp: number;
  paymentFeesGbp: number;
  taxReserveGbp: number;
  contingencyReserveGbp: number;
  usableBuildFundsGbp: number;
}
