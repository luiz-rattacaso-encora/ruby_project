require 'swagger_helper'

RSpec.describe 'Weekly Updates API', type: :request do
  path '/teams/{team_id}/weekly_updates.json' do
    parameter name: :team_id, in: :path, type: :integer, description: 'Team ID'

    get 'Lists weekly updates for the current week of a team' do
      tags 'Weekly Updates'
      produces 'application/json'
      parameter name: :author_name, in: :query, type: :string, required: false, description: 'Filter by author name'
      parameter name: :status, in: :query, type: :string, required: false, description: 'Filter by status'

      response '200', 'weekly updates listed successfully' do
        run_test!
      end

      response '403', 'forbidden to access this team' do
        run_test!
      end

      response '404', 'team not found' do
        run_test!
      end
    end

    post 'Creates a weekly update for a team' do
      tags 'Weekly Updates'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :weekly_update, in: :body, schema: {
        type: :object,
        properties: {
          weekly_update: {
            type: :object,
            properties: {
              content: { type: :string },
              status: { type: :string }
            },
            required: %w[content status]
          }
        }
      }

      response '201', 'weekly update created' do
        run_test!
      end

      response '403', 'forbidden to create update for this team' do
        run_test!
      end

      response '422', 'unprocessable entity' do
        run_test!
      end
    end
  end

  path '/weekly_updates/{id}.json' do
    parameter name: :id, in: :path, type: :integer, description: 'Weekly Update ID'

    get 'Retrieves a specific weekly update' do
      tags 'Weekly Updates'
      produces 'application/json'

      response '200', 'weekly update found' do
        run_test!
      end

      response '403', 'forbidden to view this update' do
        run_test!
      end

      response '404', 'weekly update not found' do
        run_test!
      end
    end

    patch 'Updates a weekly update' do
      tags 'Weekly Updates'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :weekly_update, in: :body, schema: {
        type: :object,
        properties: {
          weekly_update: {
            type: :object,
            properties: {
              content: { type: :string },
              status: { type: :string }
            }
          }
        }
      }

      response '200', 'weekly update modified' do
        run_test!
      end

      response '403', 'forbidden to modify this update' do
        run_test!
      end

      response '422', 'unprocessable entity' do
        run_test!
      end
    end

    delete 'Deletes a weekly update' do
      tags 'Weekly Updates'
      produces 'application/json'

      response '204', 'weekly update deleted' do
        run_test!
      end

      response '403', 'forbidden to delete this update' do
        run_test!
      end
    end
  end
end
