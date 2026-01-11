module TudlaHubstaff
  module UI
    class ModalComponent < TudlaHubstaff::BaseComponent
      renders_one :header
      renders_one :body
      renders_one :footer

      def initialize(id:, title: nil, stimulus_controller: nil)
        @id = id
        @title = title
        @stimulus_controller = stimulus_controller
      end

      attr_reader :id, :title, :stimulus_controller
    end
  end
end
