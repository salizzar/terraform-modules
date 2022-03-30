import * as cdk from '@aws-cdk/core';
import * as cloudwatch from '@aws-cdk/aws-cloudwatch';
import {GraphWidget, Metric} from "@aws-cdk/aws-cloudwatch";
import * as payload from './payload';

export class CloudwatchDashboardsStack extends cdk.Stack {
  constructor(scope: cdk.App, id: string, props?: cdk.StackProps) {
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

  buildCloudwatchWidget(title: string, namespace: string, metricName: string, dimensions: Object, statistic: string): GraphWidget {
    return new GraphWidget({
      title: title,
      left: [new Metric({
        namespace: namespace,
        metricName: metricName,
        dimensions: dimensions,
        statistic: statistic
      })]
    })
  }
}
