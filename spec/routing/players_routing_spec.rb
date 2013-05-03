require "spec_helper"

describe PlayersController do
  describe "routing" do

    it "routes to #index" do
      get("/players").should route_to("players#index")
    end

    it "routes to #new" do
      get("/players/new").should route_to("players#new")
    end

    it "routes to #show" do
      get("/players/1").should route_to("players#show", :id => "1")
    end

    it "routes to #edit" do
      get("/players/1/edit").should route_to("players#edit", :id => "1")
    end

    it "routes to #create" do
      post("/players").should route_to("players#create")
    end

    it "routes to #update" do
      put("/players/1").should route_to("players#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/players/1").should route_to("players#destroy", :id => "1")
    end

  end
end
