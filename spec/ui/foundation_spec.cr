require "../spec_helper"

describe "Tailwind CSS UI Redesign" do
  describe "Header Template" do
    it "includes Tailwind CSS CDN" do
      response = HTTP::Client.get("http://localhost:4000/signin")
      response.status_code.should eq 200
      response.body.should contain("cdn.tailwindcss.com")
    end

    it "does not include Bootstrap CSS CDN" do
      response = HTTP::Client.get("http://localhost:4000/signin")
      response.status_code.should eq 200
      response.body.should_not contain("bootstrap@5.1.3/dist/css/bootstrap.min.css")
    end

    it "does not include Bootstrap JS CDN" do
      response = HTTP::Client.get("http://localhost:4000/signin")
      response.status_code.should eq 200
      response.body.should_not contain("bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js")
    end

    it "includes Inter font family" do
      response = HTTP::Client.get("http://localhost:4000/signin")
      response.status_code.should eq 200
      response.body.should contain("fonts.googleapis.com")
      response.body.should contain("Inter")
    end

    it "includes Tailwind configuration with authority colors" do
      response = HTTP::Client.get("http://localhost:4000/signin")
      response.status_code.should eq 200
      response.body.should contain("tailwind.config")
      response.body.should contain("authority")
      response.body.should contain("#2389cd")
    end
  end

  describe "Layout Template" do
    it "has proper HTML structure with Tailwind body classes" do
      response = HTTP::Client.get("http://localhost:4000/signin")
      response.status_code.should eq 200
      response.body.should contain("bg-gray-50")
    end

    it "supports dark mode class strategy" do
      response = HTTP::Client.get("http://localhost:4000/signin")
      response.status_code.should eq 200
      response.body.should contain("darkMode")
    end
  end

  describe "Login Page (new_session_form)" do
    it "renders login page successfully" do
      response = HTTP::Client.get("http://localhost:4000/signin")
      response.status_code.should eq 200
    end

    it "has centered card layout with Tailwind classes" do
      response = HTTP::Client.get("http://localhost:4000/signin")
      response.body.should contain("min-h-screen")
      response.body.should contain("flex")
      response.body.should contain("items-center")
      response.body.should contain("justify-center")
    end

    it "has card with shadow and rounded corners" do
      response = HTTP::Client.get("http://localhost:4000/signin")
      response.body.should contain("bg-white")
      response.body.should contain("shadow")
      response.body.should contain("rounded")
    end

    it "has properly styled form inputs" do
      response = HTTP::Client.get("http://localhost:4000/signin")
      response.body.should contain("border")
      response.body.should contain("focus:ring")
    end

    it "has primary button with authority color" do
      response = HTTP::Client.get("http://localhost:4000/signin")
      response.body.should contain("bg-authority")
    end

    it "preserves form action and hidden fields" do
      response = HTTP::Client.get("http://localhost:4000/signin")
      response.body.should contain("action=\"/signin\"")
      response.body.should contain("forward_url")
      response.body.should contain("name=\"username\"")
      response.body.should contain("name=\"password\"")
    end

    it "has link to signup page" do
      response = HTTP::Client.get("http://localhost:4000/signin")
      response.body.should contain("href=\"/signup\"")
    end
  end

  describe "Registration Page (new_owner_form)" do
    it "renders registration page successfully" do
      response = HTTP::Client.get("http://localhost:4000/signup")
      response.status_code.should eq 200
    end

    it "has centered card layout with Tailwind classes" do
      response = HTTP::Client.get("http://localhost:4000/signup")
      response.body.should contain("min-h-screen")
      response.body.should contain("flex")
      response.body.should contain("items-center")
    end

    it "has all required form fields" do
      response = HTTP::Client.get("http://localhost:4000/signup")
      response.body.should contain("name=\"first_name\"")
      response.body.should contain("name=\"last_name\"")
      response.body.should contain("name=\"email\"")
      response.body.should contain("name=\"username\"")
      response.body.should contain("name=\"password\"")
      response.body.should contain("name=\"confirm_password\"")
    end

    it "preserves form action" do
      response = HTTP::Client.get("http://localhost:4000/signup")
      response.body.should contain("action=\"/signup\"")
    end

    it "has link to login page" do
      response = HTTP::Client.get("http://localhost:4000/signup")
      response.body.should contain("href=\"/signin\"")
    end
  end

  describe "Device Activation Page" do
    it "renders device activation page successfully" do
      response = HTTP::Client.get("http://localhost:4000/activate")
      response.status_code.should eq 200
    end

    it "has centered card layout with Tailwind classes" do
      response = HTTP::Client.get("http://localhost:4000/activate")
      response.body.should contain("min-h-screen")
      response.body.should contain("flex")
    end

    it "has user code input field" do
      response = HTTP::Client.get("http://localhost:4000/activate")
      response.body.should contain("name=\"user_code\"")
    end

    it "has deny and allow buttons" do
      response = HTTP::Client.get("http://localhost:4000/activate")
      response.body.should contain("value=\"denied\"")
      response.body.should contain("value=\"allowed\"")
    end
  end
end
