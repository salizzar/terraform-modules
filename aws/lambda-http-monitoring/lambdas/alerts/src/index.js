const request = require('request-promise-native');

const getAlarmSubject = (message) => {
  const title = `*${message.NewStateValue}*: ${message.AlarmName}`;
  const color = message.NewStateValue == 'ALARM' ? 'danger' : 'good';

  return {color: color, title: title};
};

const getAlarmPayload = (message, color) => {
  const trigger = message.Trigger;
  console.log(`Trigger: ${JSON.stringify(trigger)}`);

  const dimensions = trigger.Dimensions[0];
  console.log(`Dimensions: ${JSON.stringify(dimensions)}`);

  return [{
    text: message.NewStateReason,
    color: color,
    fields: [
      {
        title: 'Alarm Name',
        value: message.AlarmName,
        short: false,
      },
      {
        title: 'Metric',
        value: trigger.MetricName,
        short: true,
      },
      {
        title: 'Threshold',
        value: trigger.Threshold,
        short: true,
      },
      {
        title: 'Dimension Name',
        value: dimensions.name,
        short: true,
      },
      {
        title: 'Dimension Value',
        value: dimensions.value,
        short: true,
      },
      {
        title: 'Period',
        value: trigger.Period,
        short: true,
      },
      {
        title: 'Triggered At',
        value: message.StateChangeTime,
        short: true,
      },
    ]
  }];
};

const sendMessage = (message) => {
  const payload = {
    method: 'POST',
    url: process.env.SLACK_URL,
    body: message,
    json: true,
  };

  return request(payload)
    .then((body) => {
      if (body === 'ok') {
        return {};
      } else {
        throw new Error(body);
      }
    });
};

const processRecord = (record) => {
  const message = JSON.parse(record.Sns.Message);
  console.log(`Parsed message: ${JSON.stringify(message)}`);

  const info = getAlarmSubject(message);
  const title = `CloudWatch Metric ${info.title}`;
  const payload = getAlarmPayload(message, info.color);

  return sendMessage({
    text: title,
    attachments: payload,
  });
};

exports.handler = (event, context, cb) => {
  console.log(`event received: ${JSON.stringify(event)}`);

  Promise.all(event.Records.map(processRecord))
    .then(() => cb(null))
    .catch((err) => cb(err));
};
