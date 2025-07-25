using MinimalEndpoints.Abstractions;

namespace MinimalEndpoints.Sample.Endpoints;

public class Delete : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapDelete("delete", () => "Delete endpoint");
    }
}