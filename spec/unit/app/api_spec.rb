require_relative '../../../app/api.rb'
require 'rack/test'

module ExpenseTracker
  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end

    let(:ledger) { instance_double('ExpenseTracker::Ledger')}

    describe 'POST /expenses' do

      def postExpense(expense)
        post '/expenses', JSON.generate(expense)
        {'body' => JSON.parse(last_response.body), 'status' => last_response.status}
      end
      
      context 'when the expense is successfully recorded' do
        let(:expense) { { 'some' => 'data' } }
          
        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(true, 417, nil))
        end

        it 'returns the expense id' do
          response = postExpense(expense)
          expect(response['body']).to include('expense_id' => 417)
        end

        it 'responds with a 200 (OK)' do
          response = postExpense(expense)
          expect(response['status']).to eq(200)
        end
      end
      context 'when the expense fails validation' do
        let(:expense) { { 'some' => 'data'} }

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(false, 422, 'Expense incomplete'))
        end

        it 'returns an error message' do
          response = postExpense(expense)
          expect(response['body']).to include('error' => 'Expense incomplete')
        end

        it 'responds with a 422 (Unprocessable entity)' do 
          response = postExpense(expense)
          expect(response['status']).to eq(422)
        end
      end
    end
  end
end