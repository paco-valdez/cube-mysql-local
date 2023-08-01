const host     = process.env.CUBEJS_DB_HOST;
const port     = process.env.CUBEJS_DB_PORT;
// const database = process.env.CUBEJS_DB_NAME;
const user     = process.env.CUBEJS_DB_USER;
const password = process.env.CUBEJS_DB_PASS;


module.exports = {
  queryRewrite: (query, { securityContext }) => {
    if (securityContext && securityContext.vendor_id) {
      console.log(typeof securityContext.vendor_id);
      console.log(securityContext.vendor_id);
      query.filters.push({
        member: `Vendors.id`,
        operator: 'equals',
        values: [securityContext.vendor_id],
        });
      return query;
    }
  },

  contextToAppId: ({ securityContext }) => `CUBEJS_APP_${securityContext.appID}`,
  // We also must configure preAggregationsSchema to prevent preAggregation conflicts on the same table
  preAggregationsSchema: ({ securityContext }) => `pre_aggregations_${securityContext.appID}`,

  // driverFactory: ({ dataSource }) => {
  //   console.log(dataSource);

  //   if (dataSource === 'transactions') {
  //     console.log('TRANSACTIONS ACCESSED')
  //     return {
  //       database: `transactions`,
  //       host: host,
  //       user: user,
  //       password: password,
  //       port: port,
  //     }
  //   }

  //   if(dataSource === 'reporting') {
  //     console.log('REPORTING ACCESSED');
  //     return {
  //       database: `reporting`,
  //       host: host,
  //       user: user,
  //       password: password,
  //       port: port,
  //     }
  //   }

  //   throw new Error('No valid APP ID found in Security Context!');
  // },
  scheduledRefreshContexts: async () => {
    return [
      { securityContext: { appID: 'transactions' } },
      { securityContext: { appID: 'reporting' } },
    ]
  },
};
