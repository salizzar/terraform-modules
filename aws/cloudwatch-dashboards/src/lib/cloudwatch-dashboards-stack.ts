// default from cdk
import { Stack, StackProps } from 'aws-cdk-lib';
import { Construct } from 'constructs';


// imports from cdk
import * as cloudwatch from 'aws-cdk-lib/aws-cloudwatch';
import {GraphWidget} from 'aws-cdk-lib/aws-cloudwatch';

// import payload
import * as payload from './payload';


export class CloudwatchDashboardsStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);

    payload.dashboards.forEach(dashboard => {
      const dashboardName = dashboard.name;
      const cloudwatchDashboard = new cloudwatch.Dashboard(this, dashboardName, {dashboardName: dashboardName});

      // @ts-ignore
      dashboard.applications.forEach(application => {
        // @ts-ignore
        const widgets = application.cloudwatchMetrics.map(metric => {
          // @ts-ignore
          return this.buildCloudwatchWidget(application.name, metric.namespace, metric.name, metric.dimensions, metric.statistic);
        });

        cloudwatchDashboard.addWidgets(...widgets);
      });
    });
  }

  buildCloudwatchWidget(title: string, namespace: string, metricName: string, dimensions: any, statistic: string): GraphWidget {
    return new GraphWidget({
      title: title,
      left: [new cloudwatch.Metric({
        namespace: namespace,
        metricName: metricName,
        dimensionsMap: dimensions,
        statistic: statistic
      })]
    })
  }
}
