require 'swagger_helper'

RSpec.describe 'Employees API', type: :request do
  path '/employees.json' do
    get 'Retrieves the current logged-in employee profile' do
      tags 'Employees'
      produces 'application/json'

      response '200', 'employee found' do
        run_test!
      end

      response '404', 'employee not found' do
        run_test!
      end
    end

    post 'Creates a new employee and user' do
      tags 'Employees'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :employee, in: :body, schema: {
        type: :object,
        properties: {
          employee: {
            type: :object,
            properties: {
              first_name: { type: :string },
              last_name: { type: :string },
              role: { type: :string },
              is_manager: { type: :boolean },
              manager_id: { type: :integer },
              user_attributes: {
                type: :object,
                properties: {
                  email_address: { type: :string },
                  password: { type: :string },
                  password_confirmation: { type: :string }
                },
                required: %w[email_address password password_confirmation]
              }
            },
            required: %w[first_name last_name role]
          }
        }
      }

      response '201', 'employee created' do
        run_test!
      end

      response '403', 'only managers can create employees' do
        run_test!
      end

      response '422', 'unprocessable entity' do
        run_test!
      end
    end
  end

  path '/employees/all.json' do
    get 'Lists all employees' do
      tags 'Employees'
      produces 'application/json'
      parameter name: :search_name, in: :query, type: :string, required: false, description: 'Search by employee name'

      response '200', 'employees listed successfully' do
        run_test!
      end
    end
  end

  path '/employees/{id}.json' do
    parameter name: :id, in: :path, type: :integer, description: 'Employee ID'

    get 'Retrieves details of a specific employee' do
      tags 'Employees'
      produces 'application/json'

      response '200', 'employee found' do
        run_test!
      end

      response '404', 'employee not found' do
        run_test!
      end
    end

    patch 'Updates an employee' do
      tags 'Employees'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :employee, in: :body, schema: {
        type: :object,
        properties: {
          employee: {
            type: :object,
            properties: {
              first_name: { type: :string },
              last_name: { type: :string },
              role: { type: :string },
              is_manager: { type: :boolean },
              manager_id: { type: :integer }
            }
          }
        }
      }

      response '200', 'employee updated' do
        run_test!
      end

      response '403', 'forbidden to update employee' do
        run_test!
      end

      response '422', 'unprocessable entity' do
        run_test!
      end
    end

    delete 'Deletes an employee' do
      tags 'Employees'
      produces 'application/json'

      response '204', 'employee deleted' do
        run_test!
      end

      response '403', 'forbidden to delete employee' do
        run_test!
      end
    end
  end
end
