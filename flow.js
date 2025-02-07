/*   
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

function create() {
    var context = cocoon.parameters.context;
    var create = cocoon.request.getParameter("create") ? true : false;
    var baseURL = cocoon.request.getParameter("baseURL");
    
    if (baseURL != null && baseURL.length() > 0) {
        var util = cocoon.createObject("org.apache.cocoon.samples.LuceneUtil");
        util.createIndex(baseURL, create);
    }
    if (baseURL == null || baseURL.length() < 1) {
        baseURL = "http://" + cocoon.request.getServerName()
                            + ":" + cocoon.request.getServerPort()
                            + cocoon.request.getContextPath()
                            + "/"+ context + "/";
    }
    cocoon.sendPage("editorial/create-index.jx", {"url" : baseURL, "create" : create});
}
