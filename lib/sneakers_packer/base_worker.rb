module SneakersPacker
  module BaseWorker

    def packer
      SneakersPacker.message_packer
    end

    def with_verify_active_record
      yield
    ensure
      if defined?(ActiveRecord)
        ::ActiveRecord::Base.clear_active_connections!
      end
    end
  end
end
