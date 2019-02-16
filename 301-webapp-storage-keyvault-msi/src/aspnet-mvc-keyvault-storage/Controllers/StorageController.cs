using aspnet_mvc_keyvault_storage.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Diagnostics;
using System.Threading.Tasks;

namespace aspnet_mvc_keyvault_storage.Controllers
{
    [Authorize]
    public class StorageController : Controller
    {
        private readonly IBlobRepository _client;
        private readonly ILogger _logger;

        public StorageController(IBlobRepository client, ILogger<StorageController> logger)
        {
            _client = client;
            _logger = logger;
        }

        // GET: Storage
        public async Task<IActionResult> Index()
        {
            try
            {
                _logger.LogInformation("Retrieving list of blobs");
                var blobList = await _client.GetBlobListAsync();
                _logger.LogInformation("Retrieved list of blobs");
                return View(blobList);
            }
            catch(Exception oops)
            {
                _logger.LogError(oops, "Error retrieving list of blobs");
                return RedirectToAction(nameof(Error));
            }
            
        }

        // GET: Storage/Details/5
        public async Task<IActionResult> Details(string fileName)
        {
            try
            {
                _logger.LogInformation("Retrieving blob {0}", fileName);
                var blob = await _client.GetBlobAsync(fileName);
                _logger.LogInformation("Retrieved blob {0}", fileName);
                return View(blob);
            }
            catch (Exception oops)
            {
                _logger.LogError(oops, "Error retrieving details of blob {0}", fileName);
                return RedirectToAction(nameof(Error));
            }
        }

        // GET: Storage/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: Storage/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(IFormCollection collection)
        {
            var fileName = collection["name"];
            var contents = collection["contents"];

            try
            {
                _logger.LogInformation("Creating blob - fileName:{0}, contents:{1}", fileName, contents);
                var blob = await _client.CreateBlobAsync(fileName, contents);
                _logger.LogInformation("Created blob - fileName:{0}, contents:{1}", fileName, contents);

                return RedirectToAction(nameof(Index));
            }
            catch (Exception oops)
            {
                _logger.LogError(oops, "Error creating blob. FileName: {0}, Contents: {1}", fileName, contents);
                return RedirectToAction(nameof(Error));
            }
        }




        // GET: Storage/Delete/5
        public async Task<IActionResult> Delete(string fileName)
        {
            try
            {
                _logger.LogInformation("Retrieving blob {0}", fileName);
                var blob = await _client.GetBlobAsync(fileName);
                _logger.LogInformation("Retrieved blob {0}", fileName);
                return View(blob);
            }
            catch (Exception oops)
            {
                _logger.LogError(oops, "Error retrieving details of blob {0}", fileName);
                return RedirectToAction(nameof(Error));
            }
        }

        // POST: Storage/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(IFormCollection collection)
        {
            var fileName = collection["Name"];
            
            try
            {
                _logger.LogInformation("Deleting blob - fileName:{0}", fileName);
                await _client.DeleteAsync(fileName);
                _logger.LogInformation("Deleted blob - fileName:{0}", fileName);

                return RedirectToAction(nameof(Index));
            }
            catch(Exception oops)
            {
                _logger.LogError(oops, "Error deleting blob. FileName: {0}", fileName);
                return RedirectToAction(nameof(Error));
            }
        }


        [AllowAnonymous]
        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}