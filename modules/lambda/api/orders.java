//Escribir funciones Lambda para manejar órdenes
package sushi.modules.lambda.api;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;

public class OrdersHandler implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {

    @Override
    public APIGatewayProxyResponseEvent handleRequest(APIGatewayProxyRequestEvent request, Context context) {
        return new APIGatewayProxyResponseEvent()
            .withStatusCode(200)
            .withHeaders(java.util.Collections.singletonMap("Content-Type", "application/json"))
            .withBody("{\"message\": \"hola mundo desde java\"}");
    }
}   