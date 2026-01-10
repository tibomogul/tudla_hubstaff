# desc "Explaining what the task does"
# task :tudla_hubstaff do
#   # Task goes here
# end
namespace :app do
  namespace :tailwindcss do
    desc "Watch and build Tailwind CSS for the engine"
    task :watch do
      require "tailwindcss-rails"
      # Construct the command to watch engine files and output to builds/
      cmd = "#{Tailwindcss::Commands.executable} " \
            "-i #{TudlaHubstaff::Engine.root.join("app/assets/stylesheets/tudla_hubstaff/application.css")} " \
            "-o #{TudlaHubstaff::Engine.root.join("app/assets/builds/tudla_hubstaff.css")} " \
            "--watch"
      system cmd
    end
  end
end
