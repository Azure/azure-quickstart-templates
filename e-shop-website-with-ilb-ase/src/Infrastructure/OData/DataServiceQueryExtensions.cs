/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using Microsoft.OData.Client;
using System;
using System.Linq;
using System.Linq.Expressions;

namespace Infrastructure.OData
{
    public static class DataServiceQueryExtensions
    {
        public static DataServiceQuery<TEntity> Where2<TEntity>(this DataServiceQuery<TEntity> query, Expression<Func<TEntity, bool>> criteria)
        {
            return (DataServiceQuery<TEntity>)query.Where(criteria);
        }

        public static DataServiceQuery<TEntity> Take2<TEntity>(this DataServiceQuery<TEntity> query, int count)
        {
            return (DataServiceQuery<TEntity>)query.Take(count);
        }
    }
}
