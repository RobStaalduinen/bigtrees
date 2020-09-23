describe CustomersController do
  render_views

  let(:arborist) { create(:admin) }

  before do
    log_in_user(arborist)
  end

  describe "#index" do
    let(:params) { {} }
    subject(:get_request) do
      get :index, params.merge({format: :json})
      response
    end
    let(:parsed_response) { JSON.parse(get_request.body) }
    let(:customers) { parsed_response['customers'] }

    it { should have_http_status(:ok) }

    context 'with no customers' do
      it 'returns empty list' do
        expect(customers.count).to eq(0)
      end
    end

    context 'with customer' do
      let!(:customer) { create(:customer) }

      it 'returns customer' do
        expect(customers.count).to eq(1)
      end

      it 'has correct attributes' do
        expect(customers.first).to have_key('name')
        expect(customers.first).to have_key('email')
        expect(customers.first).to have_key('phone')
        expect(customers.first).to have_key('preferred_contact')
      end
    end

    describe 'Pagination' do
      before do
        5.times do
          create(:customer)
        end
      end

      context 'with per_page param' do
        let(:params) { { per_page: 3 } }

        it 'limits results based on per_page' do
          expect(customers.count).to eq(3)
          expect(parsed_response['total_entries']).to eq(5)
        end
      end

      context 'with page param' do
        let(:params) { { per_page: 3, page: 2 } }

        it 'rolls over to following page' do
          expect(customers.count).to eq(2)
          expect(parsed_response['total_entries']).to eq(5)
        end
      end
    end

    describe 'Search' do
      let(:params) { { q: search_query } }
      let!(:first_customer) { create(:customer, name: 'Rob van Staalduinen', email: 'robstaal@gmail.com') }
      let!(:second_customer) { create(:customer, name: 'Tyler Brewer', email: 'tbrewer@gmail.com') }

      context 'with search query matching name' do
        let(:search_query) { 'Tyler' }

        it 'returns only matching names' do
          expect(customers.count).to eq(1)
          expect(customers.first['id']).to eq(second_customer.id)
        end
      end

      context 'with search query matching email' do
        let(:search_query) { 'robstaal' }

        it 'returns only matching email' do
          expect(customers.count).to eq(1)
          expect(customers.first['id']).to eq(first_customer.id)
        end
      end
    end
  end

end
