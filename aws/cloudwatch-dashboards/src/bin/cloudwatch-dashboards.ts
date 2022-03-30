#!/usr/bin/env node
import * as cdk from '@aws-cdk/core';
import { CloudwatchDashboardsStack } from '../lib/cloudwatch-dashboards-stack';

const app = new cdk.App();
new CloudwatchDashboardsStack(app, 'CloudwatchDashboardsStack');
