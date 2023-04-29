# frozen_string_literal: true

class BaseQuery
  include Dry::Monads[:result]

  def call(params)
    run(params) do |m|
      m.success do |data|
        [200, { 'Content-Type': 'application/json' }, JSON.dump(data)]
      end

      m.failure(Dry::Validation::Result) do |errors|
        body = { errors: errors.errors.to_h }
        status = errors.errors.to_h.values.flatten.include?('record_not_found') ? 404 : 422
        [status, { 'Content-Type' => 'application/json' }, body.to_json]
      end

      m.failure(Errors::NoDataError) do
        [418, { 'Content-Type' => 'application/json' }, '{"error": "No data"}']
      end
    end
  end
end
