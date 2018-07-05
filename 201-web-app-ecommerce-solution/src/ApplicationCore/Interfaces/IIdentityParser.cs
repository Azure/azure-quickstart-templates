using System.Security.Principal;

namespace ApplicationCore.Interfaces
{
    public interface IIdentityParser<T>
    {
        T Parse(IPrincipal principal);
    }
}
