describe SessionsController do
  
  describe "new" do
    context "with unauthenticated user" do
      it "renders new template" do
        get :new
        expect(response).to render_template(:new)
      end
    end

    context "with authenticated user" do
      

    
    end
  end

  describe "create" do
    context "for non-existent user" do
      it "redirects to login" do
        post :create, { email: 'notauser@email.com' }
        redirect_to(login_path)
      end

      it "does not set a session token" do
        post :create, { email: 'notauser@email.com' }
        expect(cookies[:session_token]).to eq(nil)
      end
    end

    context "with invalid password" do
      let!(:arborist) { create(:arborist) }

      it "redirects to login" do
        post :create, { email: arborist.email, password: 'wrong_password' }
        redirect_to(login_path)
      end

      it "does not set a session token" do
        post :create, { email: arborist.email, password: 'wrong_password' }
        expect(cookies[:session_token]).to eq(nil)
      end
    end

    context "with valid user" do
      let!(:arborist) { create(:arborist) }

      context "for admin" do
        it "redirects to estmates path" do
          post :create, { email: arborist.email, password: arborist.password }
          redirect_to(estimates_path)
        end

        it "sets a session token" do
          post :create, { email: arborist.email, password: arborist.password }
          expect(cookies[:session_token]).not_to eq(nil)
          expect(cookies[:session_token]).to eq(arborist.session_token)
        end
      end

    
    end
  end
end
