describe EstimatesController do
  let!(:arborist) { FactoryBot.create(:admin) }

  before do
    log_in_user(arborist)
  end

  describe '#create' do
    subject(:create) { post :create, params }
    let(:params) { }

    context 'with notes' do
      let(:params) do
        {
          estimate: {
            notes_attributes: [{
              content: 'Test content',
              image_attributes: {
                image_url: 'test.com/url'
              }
            }]
          }
        }
      end

      it 'creates a note and image' do
        expect {
          expect {
            create
          }.to change(Note, :count).by(1)
        }.to change(Image, :count).by(1)

      end
    end
  end
end
