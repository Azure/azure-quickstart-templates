/*   
 *   * Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the MIT license.  
 *   * See LICENSE in the project root for license information.  
 */

using System.Collections.Generic;
using System.Threading.Tasks;

namespace ApplicationCore.Interfaces
{
    public interface IBasketService
    {
        Task<int> GetBasketItemCountAsync(string userName);

        Task TransferBasketAsync(string anonymousId, string userName);

        Task AddItemToBasket(int basketId, int catalogItemId, decimal price, int quantity);

        Task SetQuantities(int basketId, Dictionary<string, int> quantities);

        Task DeleteBasketAsync(int basketId);
    }
}
