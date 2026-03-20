ARG APP_VERSION=v15
FROM frappe/erpnext:${APP_VERSION}

# Determine HRMS branch based on APP_VERSION
ARG APP_VERSION
RUN HRMS_BRANCH=$(echo ${APP_VERSION} | sed 's/^v/version-/') && \
    INDIA_BRANCH=$(echo ${APP_VERSION} | sed 's/^v/version-/') && \
    cd /home/frappe/frappe-bench/apps && \
    # Install HRMS
    git clone --depth 1 --branch ${HRMS_BRANCH} https://github.com/frappe/hrms && \
    rm -rf hrms/.git && \
    # Install CRM
    git clone --depth 1 --branch main https://github.com/frappe/crm && \
    rm -rf crm/.git && \
    # Install Telephony (required by CRM)
    git clone --depth 1 --branch develop https://github.com/frappe/telephony && \
    rm -rf telephony/.git && \
    # Install Helpdesk
    git clone --depth 1 --branch main https://github.com/frappe/helpdesk && \
    rm -rf helpdesk/.git && \
    # Install Insights
    git clone --depth 1 --branch main https://github.com/frappe/insights && \
    rm -rf insights/.git && \
    # Install Wiki
    git clone --depth 1 --branch develop https://github.com/frappe/wiki && \
    rm -rf wiki/.git && \
    # Install Drive
    git clone --depth 1 --branch main https://github.com/frappe/drive && \
    rm -rf drive/.git && \
    # Install India Compliance (note: repo has hyphen but Python package uses underscore)
    git clone --depth 1 --branch ${INDIA_BRANCH} https://github.com/resilient-tech/india-compliance && \
    rm -rf india-compliance/.git && \
    mv india-compliance india_compliance && \
    # Install Python dependencies for all apps
    cd /home/frappe/frappe-bench && \
    /home/frappe/frappe-bench/env/bin/pip install -e apps/hrms && \
    /home/frappe/frappe-bench/env/bin/pip install -e apps/crm && \
    /home/frappe/frappe-bench/env/bin/pip install -e apps/telephony && \
    /home/frappe/frappe-bench/env/bin/pip install -e apps/helpdesk && \
    /home/frappe/frappe-bench/env/bin/pip install -e apps/insights && \
    /home/frappe/frappe-bench/env/bin/pip install -e apps/wiki && \
    /home/frappe/frappe-bench/env/bin/pip install -e apps/drive && \
    /home/frappe/frappe-bench/env/bin/pip install -e apps/india_compliance

USER frappe
