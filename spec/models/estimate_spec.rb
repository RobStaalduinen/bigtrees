require 'rails_helper'

RSpec.describe Estimate, type: :model do
  let(:organization) { create(:organization) }
  let(:arborist)     { create(:arborist, :admin, organization: organization) }
  let(:customer)     { create(:customer) }

  # Helper: build a base estimate that satisfies INNER joins (site + customer_detail)
  # and bypass set_status so we can control status in setup.
  def build_estimate(overrides = {})
    estimate = create(:estimate, :complete,
                      organization: organization,
                      arborist: arborist,
                      customer: customer)
    overrides.each { |k, v| estimate.update_column(k, v) }
    estimate.reload
  end

  describe '#set_status' do
    context 'when the estimate has no costs' do
      it 'sets status to needs_costs' do
        estimate = build_estimate
        estimate.set_status
        expect(estimate.status).to eq('needs_costs')
      end
    end

    context 'when the estimate has costs but no arborist' do
      it 'sets status to needs_arborist' do
        estimate = build_estimate(arborist_id: nil)
        estimate.costs.create!(description: 'Tree removal', amount: 500)
        estimate.set_status
        expect(estimate.status).to eq('needs_arborist')
      end
    end

    context 'when the estimate has an arborist and costs but no quote_sent_date' do
      it 'sets status to pending_quote' do
        estimate = build_estimate
        estimate.costs.create!(description: 'Tree removal', amount: 500)
        estimate.set_status
        expect(estimate.status).to eq('pending_quote')
      end
    end

    context 'when the estimate has a quote_sent_date but is not approved' do
      it 'sets status to quote_sent' do
        estimate = build_estimate(quote_sent_date: Date.today, approved: false)
        estimate.costs.create!(description: 'Tree removal', amount: 500)
        estimate.set_status
        expect(estimate.status).to eq('quote_sent')
      end
    end

    context 'when the estimate is approved but has no work_start_date and is not skipped' do
      it 'sets status to approved' do
        estimate = build_estimate(quote_sent_date: Date.today, approved: true,
                                  work_start_date: nil, skip_schedule: false)
        estimate.costs.create!(description: 'Tree removal', amount: 500)
        estimate.set_status
        expect(estimate.status).to eq('approved')
      end
    end

    context 'when the estimate has a work_start_date and the job has not started' do
      it 'sets status to work_scheduled' do
        estimate = build_estimate(quote_sent_date: Date.today, approved: true,
                                  work_start_date: Date.today)
        estimate.costs.create!(description: 'Tree removal', amount: 500)
        job = Job.create!(estimate: estimate)
        estimate.set_status
        expect(estimate.status).to eq('work_scheduled')
      end
    end

    context 'when the job has started but not completed' do
      it 'sets status to work_started' do
        estimate = build_estimate(quote_sent_date: Date.today, approved: true,
                                  work_start_date: Date.today)
        estimate.costs.create!(description: 'Tree removal', amount: 500)
        Job.create!(estimate: estimate, started_at: Time.now)
        estimate.set_status
        expect(estimate.status).to eq('work_started')
      end
    end

    context 'when the job is completed and the invoice has not been sent' do
      it 'sets status to work_completed' do
        estimate = build_estimate(quote_sent_date: Date.today, approved: true,
                                  work_start_date: Date.today)
        estimate.costs.create!(description: 'Tree removal', amount: 500)
        Job.create!(estimate: estimate, started_at: Time.now, completed_at: Time.now)
        estimate.set_status
        expect(estimate.status).to eq('work_completed')
      end
    end

    context 'when the job is skipped and the invoice has not been sent' do
      it 'sets status to work_completed' do
        estimate = build_estimate(quote_sent_date: Date.today, approved: true,
                                  work_start_date: Date.today)
        estimate.costs.create!(description: 'Tree removal', amount: 500)
        Job.create!(estimate: estimate, skipped: true)
        estimate.set_status
        expect(estimate.status).to eq('work_completed')
      end
    end

    context 'when the invoice has been sent but not paid' do
      it 'sets status to final_invoice_sent' do
        estimate = build_estimate(quote_sent_date: Date.today, approved: true,
                                  work_start_date: Date.today)
        estimate.costs.create!(description: 'Tree removal', amount: 500)
        Job.create!(estimate: estimate, started_at: Time.now, completed_at: Time.now)
        Invoice.create!(estimate: estimate, sent_at: Date.today, paid: false)
        estimate.set_status
        expect(estimate.status).to eq('final_invoice_sent')
      end
    end

    context 'when the invoice has been paid' do
      it 'sets status to completed' do
        estimate = build_estimate(quote_sent_date: Date.today, approved: true,
                                  work_start_date: Date.today)
        estimate.costs.create!(description: 'Tree removal', amount: 500)
        Job.create!(estimate: estimate, started_at: Time.now, completed_at: Time.now)
        Invoice.create!(estimate: estimate, sent_at: Date.today, paid: true, paid_at: Date.today)
        estimate.set_status
        expect(estimate.status).to eq('completed')
      end

      it 'sets state to done' do
        estimate = build_estimate(quote_sent_date: Date.today, approved: true,
                                  work_start_date: Date.today)
        estimate.costs.create!(description: 'Tree removal', amount: 500)
        Job.create!(estimate: estimate, started_at: Time.now, completed_at: Time.now)
        Invoice.create!(estimate: estimate, sent_at: Date.today, paid: true, paid_at: Date.today)
        estimate.set_status
        expect(estimate.state).to eq('done')
      end
    end

    describe 'side-effects on status change' do
      it 'resets picture_request_sent_at when status changes' do
        estimate = build_estimate(picture_request_sent_at: Date.today)
        # status starts as needs_costs; adding a cost will transition to pending_quote
        estimate.costs.create!(description: 'Tree removal', amount: 500)
        estimate.set_status
        expect(estimate.picture_request_sent_at).to be_nil
      end

      it 'resets followup_sent_at when status changes' do
        estimate = build_estimate(followup_sent_at: 1.day.ago)
        estimate.costs.create!(description: 'Tree removal', amount: 500)
        estimate.set_status
        expect(estimate.followup_sent_at).to be_nil
      end

      it 'sets state to in_progress when status changes (unless already done)' do
        estimate = build_estimate(state: 'on_hold')
        estimate.costs.create!(description: 'Tree removal', amount: 500)
        estimate.set_status
        expect(estimate.state).to eq('in_progress')
      end

      it 'preserves state=done when status changes to completed' do
        estimate = build_estimate(quote_sent_date: Date.today, approved: true,
                                  work_start_date: Date.today)
        estimate.costs.create!(description: 'Tree removal', amount: 500)
        Job.create!(estimate: estimate, started_at: Time.now, completed_at: Time.now)
        Invoice.create!(estimate: estimate, sent_at: Date.today, paid: true, paid_at: Date.today)
        estimate.set_status
        expect(estimate.state).to eq('done')
      end
    end
  end
end
