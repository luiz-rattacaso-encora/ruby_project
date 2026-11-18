require 'swagger_helper'

RSpec.describe 'Memberships API', type: :request do
  path '/memberships' do
    get 'Lists active team memberships' do
      tags 'Memberships'
      produces 'application/json'
      parameter name: :search_name, in: :query, type: :string, required: false, description: 'Filter by employee name'

      response '200', 'memberships listed successfully' do
        run_test!
      end
    end

    post 'Adds an employee to a team' do
      tags 'Memberships'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :membership, in: :body, schema: {
        type: :object,
        properties: {
          membership: {
            type: :object,
            properties: {
              employee_id: { type: :integer },
              team_id: { type: :integer }
            },
            required: %w[employee_id team_id]
          }
        }
      }

      response '201', 'membership created' do
        run_test!
      end

      response '422', 'unprocessable entity' do
        run_test!
      end
    end
  end

  path '/memberships/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Membership ID'

    get 'Retrieves details of a membership' do
      tags 'Memberships'
      produces 'application/json'

      response '200', 'membership found' do
        run_test!
      end

      response '404', 'membership not found' do
        run_test!
      end
    end

    patch 'Updates a membership' do
      tags 'Memberships'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :membership, in: :body, schema: {
        type: :object,
        properties: {
          membership: {
            type: :object,
            properties: {
              employee_id: { type: :integer },
              team_id: { type: :integer }
            }
          }
        }
      }

      response '200', 'membership updated' do
        run_test!
      end

      response '422', 'unprocessable entity' do
        run_test!
      end
    end

    delete 'Finishes a membership (sets finished_at timestamp)' do
      tags 'Memberships'
      produces 'application/json'

      response '204', 'membership finished' do
        run_test!
      end

      response '422', 'could not finish membership' do
        run_test!
      end
    end
  end
end
