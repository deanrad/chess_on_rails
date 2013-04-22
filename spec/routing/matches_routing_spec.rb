require "spec_helper"

describe MatchesController do
  describe "routing" do

    it "routes to #index" do
      get("/matches").should route_to("matches#index")
    end

    it "routes to #new" do
      get("/matches/new").should route_to("matches#new")
    end

    it "routes to #show" do
      get("/matches/1").should route_to("matches#show", :id => "1")
    end

    it "routes to #edit" do
      get("/matches/1/edit").should route_to("matches#edit", :id => "1")
    end

    it "routes to #create" do
      post("/matches").should route_to("matches#create")
    end

    it "routes to #update" do
      put("/matches/1").should route_to("matches#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/matches/1").should route_to("matches#destroy", :id => "1")
    end

  end
end
