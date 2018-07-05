using System.Threading.Tasks;

namespace ApplicationCore.Interfaces
{

    public interface IEmailSender
    {
        Task SendEmailAsync(string email, string subject, string message);
    }
}
