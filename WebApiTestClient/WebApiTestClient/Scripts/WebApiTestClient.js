var testClientModel;
var emptyTestClientModel =
{
    HttpMethod: '',
    UriPathTemplate: '',
    Samples: {},
    UriParameters: [],
    BaseAddress: '/'
};

(function () {
    function TestClientViewModel(data) {
        var self = this;
        self.HttpMethod = ko.observable(data.HttpMethod);
        self.UriPathTemplate = data.UriPathTemplate;
        self.UriPath = ko.observable(self.UriPathTemplate);

        self.UriParameters = data.UriParameters.map(function (parameter) {
            var uriParameterValue = ko.observable(parameter.value);
            uriParameterValue.subscribe(function () {
                var path = self.UriPathTemplate;
                self.UriParameters.forEach(function (parameter) {
                    var variableName = '{' + parameter.name + '}';
                    var value = parameter.value();
                    if (value != "") {
                        path = path.replace(variableName, value);
                    }
                });
                self.UriPath(path);
            });
            return { name: parameter.name, value: uriParameterValue };
        });

        self.RequestHeaders = ko.observableArray();

        self.RequestMediaType = ko.observable();

        var sampleTypes = new Array();
        for (var index in data.Samples) {
            sampleTypes.push(index);
        };
        self.SampleTypes = sampleTypes;

        self.ShouldShowBody = ko.observable(sampleTypes.length > 0);

        self.RequestBody = ko.observable();

        self.RequestMediaType.subscribe(function () {
            self.RequestBody(decodeSample(data.Samples[self.RequestMediaType()]) || "");
        });

        self.RequestBody.subscribe(function () {
            var headers = self.RequestHeaders;
            var mediaType = self.RequestMediaType();
            if (mediaType && mediaType != "") {
                addOrReplaceHeader(headers, "content-type", mediaType);
            }
            var contentLengh = self.RequestBody().length;
            addOrReplaceHeader(headers, "content-length", contentLengh);
        });

        self.addHeader = function () {
            self.RequestHeaders.splice(0, 0, { name: "", value: "" });
        };

        self.removeHeader = function (header) {
            self.RequestHeaders.remove(header);
        };

        self.baseAddress = ko.observable(data.BaseAddress);

        self.response = ko.observable();

        self.sendRequest = function () {
            var uri = self.baseAddress() + self.UriPath();
            var httpMethod = self.HttpMethod();
            var headers = self.RequestHeaders();
            var requestBody = self.RequestBody();
            SendRequest(httpMethod, uri, headers, requestBody, function (httpRequest) {
                var httpResponse = getHttpResponse(httpRequest);
                self.response(httpResponse);
                $("#testClientResponseDialog").dialog("open");
            });
        };

        $("#testClientDialog").dialog({
            autoOpen: false,
            height: "auto",
            width: "700",
            modal: true,
            open: function () {
                jQuery('.ui-widget-overlay').bind('click', function () {
                    jQuery('#testClientDialog').dialog('close');
                })
            },
            buttons: {
                "Send": function () {
                    self.sendRequest();
                }
            }
        });

        $("#testClientResponseDialog").dialog({
            autoOpen: false,
            height: "auto",
            width: "550",
            modal: true,
            open: function () {
                jQuery('.ui-widget-overlay').bind('click', function () {
                    jQuery('#testClientResponseDialog').dialog('close');
                })
            }
        });

        $("#testClientButton").click(function () {
            $("#testClientDialog").dialog("open");
        });
    }

    // Initiate the Knockout bindings
    var initialModel = testClientModel || emptyTestClientModel;
    ko.applyBindings(new TestClientViewModel(initialModel));
})();

function decodeSample(sampleString) {
    return unescape(sampleString).replace(/\+/gi, " ").replace(/\r\n/gi, "\n");
}

function addOrReplaceHeader(headers, headerName, headerValue) {
    var headerList = headers();
    for (var i in headerList) {
        if (headerList[i].name.toLowerCase() == headerName) {
            headers.replace(headerList[i], { name: headerList[i].name, value: headerValue });
            return;
        }
    }
    headers.push({ name: headerName, value: headerValue });
}

function SendRequest(httpMethod, url, requestHeaders, requestBody, handleResponse) {
    if (httpMethod.length == 0) {
        alert("HTTP Method should not be empty");
        return false;
    }

    if (url.length == 0) {
        alert("Url should not be empty");
        return false;
    }

    var httpRequest = new XMLHttpRequest();
    try {
        httpRequest.open(httpMethod, encodeURI(url), false);
    }
    catch (e) {
        alert("Cannot send request. Check the security setting of your browser if you are sending request to a different domain.");
        return false;
    }

    httpRequest.setRequestHeader("If-Modified-Since", new Date(0));
    try {
        for (var i in requestHeaders) {
            var header = requestHeaders[i];
            httpRequest.setRequestHeader(header.name, header.value);
        }
    } catch (e) {
        alert("Invalid header.");
        return false;
    }

    if ($.browser.mozilla) {
        httpRequest.onload = httpRequest.onerror = httpRequest.onabort = function () {
            handleResponse(httpRequest);
        };
    }
    else {
        httpRequest.onreadystatechange = function () {
            switch (this.readyState) {
                case 4:
                    handleResponse(httpRequest);
                    break;
                default:
                    break;
            }
        }
    }

    httpRequest.ontimeout = function () {
        alert("Request timed out.");
    }

    httpRequest.send(requestBody);
    return true;
}

function getHttpResponse(httpRequest) {
    var statusCode = httpRequest.status;
    var statusText = httpRequest.statusText;
    var responseHeaders = httpRequest.getAllResponseHeaders();
    var rawResponse = httpRequest.responseText;

    // IE - #1450: sometimes returns 1223 when it should be 204
    if (statusCode === 1223) {
        statusCode = 204;
        statusText = "No Content";
    }

    var responseStatus = statusCode + "/" + statusText;

    return { status: responseStatus, headers: responseHeaders, content: rawResponse };
}