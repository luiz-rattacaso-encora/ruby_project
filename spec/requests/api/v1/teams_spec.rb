require 'swagger_helper'

RSpec.describe 'Teams API', type: :request do
  path '/teams.json' do
    get 'Lists all teams' do
      tags 'Teams'
      produces 'application/json'
      parameter name: :search_name, in: :query, type: :string, required: false, description: 'Search team by name'

      response '200', 'teams listed successfully' do
        run_test!
      end
    end

    post 'Creates a new team' do
      tags 'Teams'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :team, in: :body, schema: {
        type: :object,
        properties: {
          team: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              technologies: { type: :string }
            },
            required: %w[name]
          }
        }
      }

      response '201', 'team created' do
        run_test!
      end

      response '422', 'unprocessable content' do
        run_test!
      end
    end
  end

  path '/teams/{id}.json' do
    parameter name: :id, in: :path, type: :integer, description: 'Team ID'

    get 'Retrieves details of a team' do
      tags 'Teams'
      produces 'application/json'

      response '200', 'team found' do
        run_test!
      end
    end

    patch 'Updates a team' do
      tags 'Teams'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :team, in: :body, schema: {
        type: :object,
        properties: {
          team: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              technologies: { type: :string }
            }
          }
        }
      }

      response '200', 'team updated' do
        run_test!
      end

      response '422', 'unprocessable content' do
        run_test!
      end
    end

    delete 'Deletes a team' do
      tags 'Teams'
      produces 'application/json'

      response '204', 'team deleted' do
        run_test!
      end
    end
  end
end
