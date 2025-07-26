using MinimalEndpoints.Abstractions;

namespace MinimalEndpoints.Sample.Endpoints;

public class Post : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("post", () => "Post endpoint");
    }
}