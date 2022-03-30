const request = require('request-promise-native');

const sendMessage = (message) => {
  return request({
    method: 'POST',
    url: process.env.SLACK_URL,
    body: message,
    json: true,
  })
      .then((body) => {
        if (body === 'ok') {
          return {};
        } else {
          throw new Error(body);
        }
      });
};

const getAlarmSubject = (message) => {
  const title = `${message.NewStateValue}: ${message.AlarmName}`;
  const color = message.NewStateValue == 'ALARM' ? 'danger' : 'good';

  return {color: color, title: title};
};

const getNotificationSubject = (message) => {
  const detail = message.detail;

  const taskWillStart = detail.desiredStatus == 'RUNNING' &&
    detail.lastStatus == 'PROVISIONING';

  const taskInProgress = detail.desiredStatus == 'RUNNING' &&
    detail.lastStatus == 'PENDING';

  const taskIsRunning = detail.desiredStatus == 'RUNNING' &&
    detail.lastStatus == 'RUNNING';

  const taskWillStop = detail.desiredStatus == 'STOPPED' &&
    detail.lastStatus == 'RUNNING';

  const taskIsStopping = detail.desiredStatus == 'STOPPED' &&
    detail.lastStatus == 'DEPROVISIONING';

  const taskIsStopped = detail.desiredStatus == 'STOPPED' &&
    detail.lastStatus == 'STOPPED';

  const taskIsFailing = detail.stoppedReason &&
    detail.stoppedReason.startsWith('Task failed container health checks');

  const failedELBHealthCheck = detail.stoppedReason &&
    detail.stoppedReason.startsWith('Task failed ELB health checks in');

  const scalingInProgress = detail.stoppedReason &&
    detail.stoppedReason.startsWith('Scaling activity initiated by');


  // happiness

  if (taskWillStart) {
    return {
      color: 'warning',
      title: 'INFO: Task Definition Launch will START',
    };
  }

  if (taskInProgress) {
    return {
      color: 'warning',
      title: 'INFO: Task Definition Launch in PROGRESS',
    };
  }

  if (taskIsRunning && !taskIsFailing && !scalingInProgress) {
    return {
      color: 'good',
      title: 'INFO: Task Definition is RUNNING',
    };
  }

  if (taskWillStop && scalingInProgress) {
    return {
      color: 'warning',
      title: 'INFO: Task Definition will be stopped by SCALING',
    };
  }

  if (taskIsStopping && scalingInProgress) {
    return {
      color: 'warning',
      title: 'INFO: Task Definition is stopping by SCALING',
    };
  }

  if (taskIsStopped && scalingInProgress) {
    return {
      color: 'warning',
      title: 'INFO: Task Definition stopped by SCALING',
    };
  }

  // nightmare 1

  if (taskWillStop && taskIsFailing) {
    return {
      color: 'danger',
      title: 'ERROR: Task Definition will be stopped by FAILURE',
    };
  }

  if (taskIsStopping && taskIsFailing) {
    return {
      color: 'danger',
      title: 'ERROR: Task Definition is stopping by FAILURE',
    };
  }

  if (taskIsStopped && taskIsFailing) {
    return {
      color: 'danger',
      title: 'ERROR: Task Definition stopped by FAILURE',
    };
  }

  // nightmare 2

  if (taskWillStop && failedELBHealthCheck) {
    return {
      color: 'danger',
      title: 'ERROR: Task Definition is FAILING due for ELB Health Check Error',
    };
  }

  if (taskIsStopping && failedELBHealthCheck) {
    return {
      color: 'danger',
      title: 'ERROR: Task Definition is stopping by ELB Health Check FAILURE',
    };
  }

  if (taskIsStopped && failedELBHealthCheck) {
    return {
      color: 'danger',
      title: 'ERROR: Task Definition stopped by ELB Health Check FAILURE',
    };
  }

  return {
    color: 'warning',
    title: 'WARNING: Unknown CloudWatch Event Notification',
  };
};

const getNotificationPayload = (message, color) => {
  const detail = message.detail;

  const network = detail.attachments.find((item) => item.type == 'eni');

  let networkData;

  if (network != undefined) {
    const eniInfo = network.details;
    const subnetId = eniInfo.find((item) => item.name == 'subnetId');
    const privateIp = eniInfo.find((item) => item.name == 'privateIPv4Address');

    networkData = {
      subnetId: subnetId != undefined ? subnetId.value : 'N/A',
      privateIp: privateIp != undefined ? privateIp.value : 'N/A',
    };
  } else {
    networkData = {
      subnetId: 'N/A',
      privateIp: 'N/A',
    };
  }

  return [{
    text: detail.stoppedReason || '',
    color: color,
    fields: [
      {
        title: 'Task ID',
        value: detail.taskArn.split('/')[1],
        short: false,
      },
      {
        title: 'Started By',
        value: detail.startedBy,
        short: true,
      },
      {
        title: 'Cluster',
        value: detail.clusterArn.split('/')[1],
        short: true,
      },
      {
        title: 'Service',
        value: detail.group.split(':')[1],
        short: true,
      },
      {
        title: 'Task Definition',
        value: detail.taskDefinitionArn.split('/')[1],
        short: true,
      },
      {
        title: 'CPU',
        value: detail.cpu,
        short: true,
      },
      {
        title: 'Memory',
        value: detail.memory,
        short: true,
      },
      {
        title: 'Subnet ID',
        value: networkData.subnetId,
        short: true,
      },
      {
        title: 'Private IP',
        value: networkData.privateIp,
        short: true,
      },
      {
        title: 'Created At',
        value: detail.createdAt,
        short: true,
      },
      {
        title: 'Started At',
        value: detail.startedAt || 'N/A',
        short: true,
      },
      {
        title: 'Desired Status',
        value: detail.desiredStatus,
        short: true,
      },
      {
        title: 'Last Status',
        value: detail.lastStatus,
        short: true,
      },
      {
        title: 'Stopping At',
        value: detail.stoppingAt || 'N/A',
        short: true,
      },
      {
        title: 'Stopped At',
        value: detail.stoppedAt || 'N/A',
        short: true,
      },
    ],
  }];
};

const getEcsAlarmPayload = (message, color) => {
  const trigger = message.Trigger;
  const dimensions = trigger.Dimensions;

  const ecsDimensions = {
    clusterName: dimensions.find((item) => item.name == 'ClusterName').value,
    serviceName: dimensions.find((item) => item.name == 'ServiceName').value,
  };

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
        title: 'Cluster',
        value: ecsDimensions.clusterName,
        short: true,
      },
      {
        title: 'Service',
        value: ecsDimensions.serviceName,
        short: true,
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
        title: 'Period',
        value: trigger.Period,
        short: true,
      },
      {
        title: 'Triggered At',
        value: message.StateChangeTime,
        short: true,
      },
    ],
  }];
};

const getAlbAlarmPayload = (message, color) => {
  const trigger = message.Trigger;
  const dimensions = trigger.Dimensions;

  const lb = dimensions.find((item) => item.name == 'LoadBalancer');
  const tg = dimensions.find((item) => item.name == 'TargetGroup');

  const albDimensions = {
    loadBalancer: lb != undefined ? lb.value.split('/')[1] : 'N/A',
    targetGroup: tg != undefined ? tg.value.split('/')[1]: 'N/A',
  };

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
        title: 'Load Balancer',
        value: albDimensions.loadBalancer,
        short: true,
      },
      {
        title: 'Target Group',
        value: albDimensions.targetGroup,
        short: true,
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
        title: 'Period',
        value: trigger.Period,
        short: true,
      },
      {
        title: 'Triggered At',
        value: message.StateChangeTime,
        short: true,
      },
    ],
  }];
};

const getAlarmPayload = (message, color) => {
  const trigger = message.Trigger;

  const namespaceMap = {
    'AWS/ApplicationELB': getAlbAlarmPayload,
    'AWS/ECS': getEcsAlarmPayload,
  };

  return namespaceMap[trigger.Namespace](message, color);
};

const processRecord = (record) => {
  const message = JSON.parse(record.Sns.Message);

  let info;
  let title;
  let payload;

  if (message.AlarmName) {
    info = getAlarmSubject(message);
    title = `CloudWatch Metric ${info.title}`;
    payload = getAlarmPayload(message, info.color);
  } else {
    info = getNotificationSubject(message);
    title = `CloudWatch Event ${info.title}`;
    payload = getNotificationPayload(message, info.color);
  }

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
