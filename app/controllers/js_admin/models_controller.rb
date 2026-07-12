module JSAdmin
  class ModelsController < ApplicationController
    def index
      @resources = JSAdmin.resources
    end
  end
end
