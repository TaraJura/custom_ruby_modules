# frozen_string_literal: true

class Openai
  MAX_CHARS = 5000

  def initialize

    api_key = Rails.application.credentials.openai.apikey
    @client = OpenAI::Client.new(access_token: api_key)
    @model = 'gpt-3.5-turbo-16k-0613'
    @aml_response = 'Vytvoř mi rozsáhlé shrnutí společnosti na základě následujících informací tak aby jsi zahrnul všechny dostupné informace o této firmě v češtině:'
  end

  def question(question)
    prepare_message(question)
    perform_api_call
  rescue StandardError => e
    "An error occurred: #{e.message}"
  end

  private

  def prepare_message(question)
    truncated_question = truncate_question(question.to_s)
    @prepared_message = [{ role: 'user', content: @aml_response + truncated_question }]
  end

  def perform_api_call
    response = @client.chat(
      parameters: {
        model: @model,
        messages: @prepared_message,
        temperature: 0.7
      }
    )
    response['choices'].first['message']['content']
  end

  def truncate_question(question)
    max_question_length = MAX_CHARS - @aml_response.length
    question.length > max_question_length ? question[0...max_question_length] : question
  end
end
