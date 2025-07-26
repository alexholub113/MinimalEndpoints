using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using MinimalEndpoints.Abstractions;
using System.Reflection;

namespace MinimalEndpoints.Extensions;

/// <summary>
/// Extension methods for registering and mapping minimal API endpoints.
/// </summary>
public static class EndpointExtensions
{
    /// <summary>
    /// Registers all endpoint classes from the specified assembly that implement <see cref="IEndpoint"/>.
    /// </summary>
    /// <param name="services">The service collection to register endpoints with.</param>
    /// <param name="assembly">The assembly to scan for endpoint implementations.</param>
    /// <returns>The service collection for chaining.</returns>
    public static IServiceCollection AddEndpoints(this IServiceCollection services, Assembly assembly)
    {
        ServiceDescriptor[] serviceDescriptors = assembly
            .DefinedTypes
            .Where(type => type is { IsAbstract: false, IsInterface: false } &&
                           type.IsAssignableTo(typeof(IEndpoint)))
            .Select(type => ServiceDescriptor.Transient(typeof(IEndpoint), type))
            .ToArray();

        services.TryAddEnumerable(serviceDescriptors);

        return services;
    }

    /// <summary>
    /// Maps all registered endpoints to the application or optionally to a route group.
    /// </summary>
    /// <param name="app">The web application to map endpoints to.</param>
    /// <param name="routeGroupBuilder">Optional route group builder for organizing endpoints under a common prefix.</param>
    /// <returns>The application builder for chaining.</returns>
    public static IApplicationBuilder MapEndpoints(this WebApplication app, RouteGroupBuilder? routeGroupBuilder = null)
    {
        IEnumerable<IEndpoint> endpoints = app.Services.GetRequiredService<IEnumerable<IEndpoint>>();

        IEndpointRouteBuilder builder = routeGroupBuilder is null ? app : routeGroupBuilder;

        foreach (IEndpoint endpoint in endpoints)
        {
            endpoint.MapEndpoint(builder);
        }

        return app;
    }
}
