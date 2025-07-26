# MinimalEndpoints

A lightweight library for organizing ASP.NET Core Minimal API endpoints using a clean, class-based approach. This library provides a simple abstraction that allows you to define each endpoint as a separate class, making your API more maintainable and testable.

## Features

- ✨ **Clean Organization**: Define each endpoint as a separate class
- 🔧 **Simple Interface**: Implement a single `IEndpoint` interface
- 🚀 **Easy Integration**: Seamless integration with existing ASP.NET Core applications
- 📋 **Auto-Discovery**: Automatic endpoint registration via assembly scanning
- 🔄 **API Versioning**: Full support for API versioning with `Asp.Versioning`
- 📚 **Swagger Integration**: Works perfectly with OpenAPI/Swagger documentation
- 🎯 **.NET 9 Ready**: Built for the latest .NET version with C# 13.0 features

## Installation

```bash
dotnet add package MinimalEndpoints
```

## Quick Start

### 1. Define Your Endpoints

Create endpoint classes by implementing the `IEndpoint` interface:

```csharp
using MinimalEndpoints.Abstractions;

public class GetUsersEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("users", () => "Get all users")
           .WithName("GetUsers")
           .WithTags("Users");
    }
}

public class CreateUserEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("users", (CreateUserRequest request) => "User created")
           .WithName("CreateUser")
           .WithTags("Users");
    }
}
```

### 2. Register and Map Endpoints

In your `Program.cs`:

```csharp
using MinimalEndpoints.Extensions;

var builder = WebApplication.CreateBuilder(args);

// Register endpoints from the current assembly
builder.Services.AddEndpoints(typeof(Program).Assembly);

var app = builder.Build();

// Map all registered endpoints
app.MapEndpoints();

app.Run();
```

### 3. Advanced Usage with API Versioning

```csharp
using Asp.Versioning;
using Asp.Versioning.Builder;
using MinimalEndpoints.Extensions;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddApiVersioning(options =>
{
    options.DefaultApiVersion = new ApiVersion(1);
    options.AssumeDefaultVersionWhenUnspecified = true;
    options.ApiVersionReader = ApiVersionReader.Combine(
        new UrlSegmentApiVersionReader(),
        new QueryStringApiVersionReader(),
        new HeaderApiVersionReader("X-Version"),
        new MediaTypeApiVersionReader("ver")
    );
}).AddApiExplorer(options =>
{
    options.GroupNameFormat = "'v'VVV";
    options.SubstituteApiVersionInUrl = true;
});

builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
    {
        Title = "My API",
        Version = "v1",
        Description = "API using Minimal Endpoints with versioning."
    });
});

builder.Services.AddEndpoints(typeof(Program).Assembly);

WebApplication app = builder.Build();

ApiVersionSet apiVersionSet = app.NewApiVersionSet()
    .HasApiVersion(new ApiVersion(1))
    .ReportApiVersions()
    .Build();

RouteGroupBuilder versionedGroup = app
    .MapGroup("api/v{version:apiVersion}")
    .WithApiVersionSet(apiVersionSet);

app.MapEndpoints(versionedGroup);

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.Run();
```

## API Reference

### IEndpoint Interface

```csharp
public interface IEndpoint
{
    void MapEndpoint(IEndpointRouteBuilder app);
}
```

The core interface that all endpoints must implement. The `MapEndpoint` method is where you define your endpoint's route, HTTP method, and configuration.

### Extension Methods

#### AddEndpoints

```csharp
public static IServiceCollection AddEndpoints(this IServiceCollection services, Assembly assembly)
```

Registers all endpoint classes from the specified assembly that implement `IEndpoint`. The method:
- Scans the assembly for non-abstract, non-interface types that implement `IEndpoint`
- Registers them as transient services in the DI container
- Uses `TryAddEnumerable` to avoid duplicate registrations

#### MapEndpoints

```csharp
public static IApplicationBuilder MapEndpoints(this WebApplication app, RouteGroupBuilder? routeGroupBuilder = null)
```

Maps all registered endpoints to the application. Features:
- Resolves all `IEndpoint` services from the DI container
- Calls `MapEndpoint` on each instance
- Optionally accepts a route group builder for organizing endpoints under a common prefix

## Examples

### Basic CRUD Endpoints

```csharp
public class GetProductsEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("products", async (IProductService productService) =>
        {
            var products = await productService.GetAllAsync();
            return Results.Ok(products);
        })
        .WithName("GetProducts")
        .WithTags("Products")
        .Produces<List<Product>>();
    }
}

public class CreateProductEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPost("products", async (CreateProductRequest request, IProductService productService) =>
        {
            var product = await productService.CreateAsync(request);
            return Results.Created($"/products/{product.Id}", product);
        })
        .WithName("CreateProduct")
        .WithTags("Products")
        .Accepts<CreateProductRequest>("application/json")
        .Produces<Product>(StatusCodes.Status201Created);
    }
}

public class UpdateProductEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapPut("products/{id:int}", async (int id, UpdateProductRequest request, IProductService productService) =>
        {
            var product = await productService.UpdateAsync(id, request);
            return product is not null ? Results.Ok(product) : Results.NotFound();
        })
        .WithName("UpdateProduct")
        .WithTags("Products");
    }
}

public class DeleteProductEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapDelete("products/{id:int}", async (int id, IProductService productService) =>
        {
            var success = await productService.DeleteAsync(id);
            return success ? Results.NoContent() : Results.NotFound();
        })
        .WithName("DeleteProduct")
        .WithTags("Products");
    }
}
```

### Endpoint with Complex Logic and Dependency Injection

```csharp
public class SearchProductsEndpoint : IEndpoint
{
    public void MapEndpoint(IEndpointRouteBuilder app)
    {
        app.MapGet("products/search", async (
            string? query,
            int page = 1,
            int pageSize = 10,
            IProductService productService,
            ILogger<SearchProductsEndpoint> logger) =>
        {
            logger.LogInformation("Searching products with query: {Query}", query);
            
            var result = await productService.SearchAsync(query, page, pageSize);
            return Results.Ok(result);
        })
        .WithName("SearchProducts")
        .WithTags("Products")
        .WithOpenApi(operation =>
        {
            operation.Summary = "Search products";
            operation.Description = "Search products by name or description with pagination";
            return operation;
        });
    }
}
```

## Project Structure

```
MinimalEndpoints/
├── src/
│   └── MinimapEndpoints/
│       ├── Abstractions/
│       │   └── IEndpoint.cs
│       ├── Extensions/
│       │   └── EndpointExtensions.cs
│       └── MinimalEndpoints.csproj
└── samples/
    └── MinimalEndpoints.Sample/
        ├── Endpoints/
        │   ├── Get.cs
        │   ├── Post.cs
        │   ├── Put.cs
        │   └── Delete.cs
        ├── Program.cs
        └── MinimalEndpoints.Sample.csproj
```

## Running the Sample

1. Clone the repository
2. Navigate to the sample project:
   ```bash
   cd samples/MinimalEndpoints.Sample
   ```
3. Run the application:
   ```bash
   dotnet run
   ```
4. Open your browser to `https://localhost:7xxx/swagger` to explore the API

The sample includes basic CRUD endpoints demonstrating the library's capabilities with API versioning and Swagger documentation.

## Requirements

- .NET 9.0 or later
- ASP.NET Core
- C# 13.0 language features

## Dependencies

- `Microsoft.AspNetCore.App` (Framework Reference)
- `Microsoft.Extensions.DependencyInjection.Abstractions`

## Compatible Packages

This library works great with:
- `Asp.Versioning.Http` - For API versioning support
- `Asp.Versioning.Mvc.ApiExplorer` - For versioned API exploration
- `Swashbuckle.AspNetCore` - For OpenAPI/Swagger documentation

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

**Alex Holub** - [GitHub Profile](https://github.com/alexholub113)

## Repository

[https://github.com/alexholub113/MinimalEndpoints](https://github.com/alexholub113/MinimalEndpoints)