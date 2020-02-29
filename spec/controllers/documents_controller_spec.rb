describe DocumentsController do
  let!(:arborist) { create(:admin) }

  before do
    log_in_user(arborist)
  end

  describe "new" do
    it "renders new template" do
      get :new, { arborist_id: arborist.id }
      expect(response).to render_template(:new)
    end

    it "sets arborist" do
      get :new, { arborist_id: arborist.id }
      expect(assigns(:arborist)).not_to be_nil
    end
  end

  describe "create" do
    context "with invalid attributes" do
      let!(:attributes) { { arborist_id: arborist.id, document: { name: nil }} }

      it "renders new template" do
        post :create, attributes
        should redirect_to new_arborist_document_path
      end

      it "does not create a document" do
        expect{ 
          post :create, attributes
        }.to change(Document, :count).by(0)
      end

      it "sets an error message" do
        post :create, attributes
        expect(flash.now[:error]).not_to be_nil
      end
    end

    context "with valid attributes" do
      let!(:attributes) { { name: 'Test document', file: fixture_file_upload('files/test_file.pdf','application/pdf')} }
      describe "creation for self" do
        let!(:arborist) { create(:employee) }

        it "creates a new document" do
          expect{ 
            post :create, { arborist_id: arborist.id, document: attributes }
          }.to change(Document, :count).by(1)
        end

        it "assigns document to arborist" do
          post :create, { arborist_id: arborist.id, document: attributes }
          expect(Document.last.arborist).to eq(arborist)
        end
      end

      describe "creation for others" do
        let!(:arborist) { create(:employee) }
        let!(:second_arborist) { create(:employee) }

        it "does not create a new document" do
          expect{ 
            post :create, { arborist_id: second_arborist.id, document: attributes }
          }.to change(Document, :count).by(0)
        end
      end

      describe "admin creation for others" do
        let!(:arborist) { create(:admin) }
        let!(:second_arborist) { create(:employee) }

        it "does creates a new document" do
          expect{ 
            post :create, { arborist_id: second_arborist.id, document: attributes }
          }.to change(Document, :count).by(1)
        end
      end
    end 
  end

  describe "delete" do
    let!(:document) { create(:document) }

    it "deletes the document" do
      expect {
        delete :destroy, { arborist_id: arborist.id, id: document.id }
      }.to change(Document, :count).by(-1)
    end

    it "renders new template" do
      delete :destroy, { arborist_id: arborist.id, id: document.id }
      should redirect_to new_arborist_document_path
    end
  end

end
