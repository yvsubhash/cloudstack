package org.apache.cloudstack.utils.hypervisor;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import javax.xml.ws.handler.Handler;
import javax.xml.ws.handler.HandlerResolver;
import javax.xml.ws.handler.PortInfo;
import javax.xml.ws.handler.soap.SOAPHandler;
import javax.xml.ws.handler.soap.SOAPMessageContext;

public class SoapHeaderHandlerResolver implements HandlerResolver {

    private final List<Handler> handlerChain = new ArrayList<Handler>();

    @Override
    public List<Handler> getHandlerChain(PortInfo arg0) {
        return Collections.unmodifiableList(handlerChain);
    }

    public void addHandler(SOAPHandler<SOAPMessageContext> handler) {
        handlerChain.add(handler);
    }

    public void clearHandlerChain() {
        handlerChain.clear();
    }
}