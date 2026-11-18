require 'swagger_helper'

RSpec.describe 'Announcements API', type: :request do
  path '/announcements.json' do
    get 'Lists all announcements' do
      tags 'Announcements'
      produces 'application/json'
      parameter name: :team_id, in: :query, type: :integer, required: false, description: 'Filter by team ID'
      parameter name: :author_name, in: :query, type: :string, required: false, description: 'Filter by author name'

      response '200', 'announcements listed successfully' do
        run_test!
      end

      response '401', 'employee profile not found' do
        run_test!
      end
    end

    post 'Creates a new announcement' do
      tags 'Announcements'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :announcement, in: :body, schema: {
        type: :object,
        properties: {
          announcement: {
            type: :object,
            properties: {
              title: { type: :string },
              content: { type: :string },
              team_id: { type: :integer }
            },
            required: %w[title content team_id]
          }
        }
      }

      response '201', 'announcement created' do
        run_test!
      end

      response '403', 'forbidden to post for this team' do
        run_test!
      end

      response '422', 'unprocessable entity' do
        run_test!
      end
    end
  end

  path '/announcements/{id}.json' do
    parameter name: :id, in: :path, type: :integer, description: 'Announcement ID'

    get 'Retrieves a specific announcement' do
      tags 'Announcements'
      produces 'application/json'

      response '200', 'announcement found' do
        run_test!
      end

      response '403', 'forbidden to view announcement' do
        run_test!
      end

      response '404', 'announcement not found' do
        run_test!
      end
    end

    patch 'Updates an announcement' do
      tags 'Announcements'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :announcement, in: :body, schema: {
        type: :object,
        properties: {
          announcement: {
            type: :object,
            properties: {
              title: { type: :string },
              content: { type: :string },
              team_id: { type: :integer }
            }
          }
        }
      }

      response '200', 'announcement updated' do
        run_test!
      end

      response '403', 'forbidden to modify announcement' do
        run_test!
      end

      response '422', 'unprocessable entity' do
        run_test!
      end
    end

    delete 'Deletes an announcement' do
      tags 'Announcements'
      produces 'application/json'

      response '204', 'announcement deleted' do
        run_test!
      end

      response '403', 'forbidden to delete announcement' do
        run_test!
      end
    end
  end
end
