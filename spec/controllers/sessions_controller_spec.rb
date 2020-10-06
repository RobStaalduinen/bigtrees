describe SessionsController do
  
  describe "new" do
    context "with unauthenticated user" do
      it "renders new template" do
        get :new
        expect(response).to render_template(:new)
      end
    end

    context "with authenticated user" do
      let!(:arborist) { create(:arborist) }

      before do
        log_in_user(arborist)
      end

      context "for admin" do
        it "redirects to estimates page" do
          get :new
          should redirect_to('/admin/estimates')
        end
      end

    
    end
  end

  describe "create" do
    context "for non-existent user" do
      it "redirects to login" do
        post :create, { email: 'notauser@email.com' }
        should redirect_to(login_path)
      end

      it "does not set a session token" do
        post :create, { email: 'notauser@email.com' }
        expect(cookies[:session_token]).to eq(nil)
      end

      it "sets an error" do
        post :create, { email: 'notauser@email.com' }
        expect(flash[:error]).not_to be_nil
      end
    end

    context "with invalid password" do
      let!(:arborist) { create(:arborist) }

      it "redirects to login" do
        post :create, { email: arborist.email, password: 'wrong_password' }
        should redirect_to(login_path)
      end

      it "does not set a session token" do
        post :create, { email: arborist.email, password: 'wrong_password' }
        expect(cookies[:session_token]).to eq(nil)
      end

      it "sets an error" do
        post :create, { email: arborist.email, password: 'wrong_password' }
        expect(flash[:error]).not_to be_nil
      end
    end

    context "with valid user" do
      let!(:arborist) { create(:arborist) }

      context "for admin" do
        it "redirects to estmates path" do
          post :create, { email: arborist.email, password: arborist.password }
          should redirect_to('/admin/estimates')
        end

        it "sets a session token" do
          post :create, { email: arborist.email, password: arborist.password }
          expect(cookies[:session_token]).not_to eq(nil)
          expect(cookies[:session_token]).to eq(arborist.session_token)
        end

        it "does not set an error" do
          post :create, { email: arborist.email, password: arborist.password }
          expect(flash[:error]).to be_nil
        end
      end
    
    end
  end

  describe "destroy" do
    context "for authenticated user" do
      let!(:arborist) { create(:arborist) }

      before do
        log_in_user(arborist)
      end

      it "redirects to login path" do
        get :destroy
        should redirect_to(login_path)
      end

      it "removes session_token" do
        get :destroy
        expect(cookies[:session_token]).to eq(nil)
      end
    end
  end
end
