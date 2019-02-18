# AWS lambda function
# Endpoint path https://mftcs3n1uj.execute-api.us-east-2.amazonaws.com/production/compute/{request_id}
# Usage example curl -X POST https://mftcs3n1uj.execute-api.us-east-2.amazonaws.com/production/compute/12
# -H "Content-Type: application/json" --data '{ "timestamp": 1493758596, "data": [{ "title": "Part 1", "values": [0, 3, 5, 6, 2, 9] }, { "title": "Part 2", "values": [6, 3, 1, 3, 9, 4] }]}'

INPUT_ARRAY_LENGTH = 6

def lambda_handler(event:, context:)
  timestamp = event&.dig('body', 'timestamp')
  data = event&.dig('body', 'data')
  request_id = event&.dig('params', 'request_id')

  values_1, values_2 = ['Part 1', 'Part 2'].map do |name|
    data&.find{ |h| h['title'] == name }&.[]('values')
  end

  if [timestamp, data, request_id, values_1, values_2].any?(&:nil?) ||
    [values_1, values_2].any? do |array|
      array.length != INPUT_ARRAY_LENGTH || array.any?{ |element| !element.is_a?(Numeric) }
    end

    { status: 400, message: 'Bad Request' }
  else
    response_body = {
      request_id: request_id,
      timestamp: timestamp,
      result: { title: 'Result', values: values_1.zip(values_2).map{ |x, y| x - y } }
    }

    { status: 200, body: response_body }
  end
end
