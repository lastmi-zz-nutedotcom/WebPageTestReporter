class ObjectDownload
        include Mongoid::Document

        field :scenario_id, type: String
        field :time_of_test, type: Time
        field :object_url, type: String
        field :load_start, type: Integer
        field :download_end, type: Integer
        field :time_to_first_byte, type: Integer
        field :dns_time, type: Integer
        field :time_to_connect, type: Integer
        field :time_to_download, type: Integer
        field :download_count, type: Integer

        index({ scenario_id: 1 })
        index({ time_of_test: 1 })
        index({ object_url: 1 })

        def total_time
                (time_to_first_byte || 0) + (dns_time || 0) + (time_to_connect || 0) + (time_to_download || 0)
        end

        def speed_index
                total_time / (download_count)
        end
end
