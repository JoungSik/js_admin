module JSAdmin
  class Registry
    class << self
      def resources
        @resources ||= build_resources
      end

      def resource_for!(model_id)
        resources.find { |resource| resource.model_id == model_id } ||
          raise(ActiveRecord::RecordNotFound, "Unknown JSAdmin resource: #{model_id}")
      end

      def reset!
        @resources = nil
      end

      private

      def build_resources
        eager_load_application_models

        ActiveRecord::Base.descendants
          .select { |model_class| manageable_model?(model_class) }
          .select { |model_class| included_model?(model_class) }
          .reject { |model_class| excluded_model?(model_class) }
          .map { |model_class| Resource.new(model_class) }
          .sort_by(&:label)
      end

      def eager_load_application_models
        Rails.application.eager_load! unless Rails.application.config.eager_load
      rescue Zeitwerk::NameError
        raise
      rescue StandardError
        nil
      end

      def manageable_model?(model_class)
        model_class.name.present? &&
          !model_class.name.start_with?("ActiveRecord::") &&
          !model_class.abstract_class? &&
          model_class < ActiveRecord::Base &&
          model_class.table_exists?
      rescue ActiveRecord::ActiveRecordError, StandardError
        false
      end

      def included_model?(model_class)
        included_models = JSAdmin.configuration.included_models
        included_models.empty? || included_models.include?(model_class.name)
      end

      def excluded_model?(model_class)
        JSAdmin.configuration.excluded_models.include?(model_class.name)
      end
    end
  end
end
