class Navbools {
  bool _dashboard = true,
      _customer = false,
      _customer_add = false,
      _customer_list = false,
      _customer_paid = false,
      _customer_ledger = false,
      _customer_credit = false,
      _supplier = false,
      _supplier_add = false,
      _supplier_list = false,
      _supplier_ledger = false,
      _product = false,
      _category_add = false,
      _category_list = false,
      _unit_add = false,
      _unit_list = false,
      _brand_add = false,
      _brand_list = false,
      _product_add = false,
      _product_list = false,
      _purchase = false,
      _purchase_add = false,
      _purchase_list = false,
      _invoice = false,
      _invoice_add = false,
      _invoice_list = false,
      _invoice_pos = false,
      _returnss = false,
      _return_add = false,
      _return_supplier_list = false,
      _return_invoice_list = false,
      _return_wastage_list = false,
      _return_wastage = false,
      _return_trashbin = false,
      _stock = false,
      _stock_report = false,
      _stock_report_batch = false,
      _stock_available = false,
      _account = false,
      _account_add_account = false,
      _account_list = false,
      _transactions = false,
      _account_supplier_payment = false,
      _account_supplier_cheque = false,
      _account_customer_cheque = false,
      _account_cheque_list = false,
      _account_customer_receives = false,
      _account_selftransaction = false,
      _account_selftransactionlist = false,
      _account_report = false,
      _report = false,
      _report_add_closing = false,
      _report_closing_list = false,
      _report_sales = false,
      _report_sales_user = false,
      _report_sales_category = false,
      _report_sales_products = false,
      _report_purchase = false,
      _report_purchase_supplier = false,
      _report_purchase_category = false,
      _search = false,
      _search_product = false,
      _search_invoice = false,
      _search_purchase = false,
      _human_resource = false,
      _human_resource_employee = false,
      _human_resource_attendance = false,
      _human_resource_payroll = false,
      _human_resource_expense = false,
      _human_resource_lending = false,
      _human_resource_add_lendingperson = false,
      _human_resource_lendingpersonlist = false,
      _human_resource_personledger = false,
      _human_resource_add_lending = false,
      _human_resource_lendinglist = false,
      _hr_employee_add_designation = false,
      _hr_employee_designation_list = false,
      _hr_employee_add_employee = false,
      _hr_employee_employee_list = false,
      _hr_attendance_add_attendace = false,
      _hr_attendance_attendance_list = false,
      _hr_attendance_datewise_attendance = false,
      _hr_payroll_add_benefit = false,
      _hr_payroll_benefit_list = false,
      _hr_payroll_add_salary_setup = false,
      _hr_payroll_salary_setup_list = false,
      _hr_payroll_salary_generate = false,
      _hr_payroll_salary_sheet = false,
      _hr_payroll_salary_payment = false,
      _hr_expense_add_expense_item = false,
      _hr_expense_expense_item_list = false,
      _hr_expense_add_expense = false,
      _hr_expense_expense_list = false,
      _hr_expense_expense_satement = false,
      _management = false,
      _management_add_user = false,
      _management_user_list = false;

  get return_trashbin => _return_trashbin;

  set return_trashbin(value) {
    _return_trashbin = value;
  }

  bool get dashboard => _dashboard;

  set dashboard(bool value) {
    _dashboard = value;
  }

  get account_supplier_cheque => _account_supplier_cheque;

  set account_supplier_cheque(value) {
    _account_supplier_cheque = value;
  }

  get management => _management;

  set management(value) {
    _management = value;
  }

  get return_wastage => _return_wastage;

  set return_wastage(value) {
    _return_wastage = value;
  }

  void setnavbool() {
    _dashboard = false;
    _customer = false;
    _customer_add = false;
    _customer_list = false;
    _customer_paid = false;
    _customer_ledger = false;
    _customer_credit = false;
    _supplier = false;
    _return_wastage = false;
    _supplier_add = false;
    _return_trashbin = false;
    _transactions = false;
    _supplier_list = false;
    _supplier_ledger = false;
    _product = false;
    _category_add = false;
    _category_list = false;
    _unit_add = false;
    _account_supplier_cheque = false;
    _account_customer_cheque = false;
    _account_cheque_list = false;
    _unit_list = false;
    _management = false;
    _management_add_user = false;
    _management_user_list = false;
    _brand_add = false;
    _brand_list = false;
    _human_resource_lending = false;
    _human_resource_add_lending = false;
    _human_resource_lendinglist = false;
    _human_resource_add_lendingperson = false;
    _human_resource_lendingpersonlist = false;
    _human_resource_personledger = false;
    _report_purchase_supplier = false;
    _product_add = false;
    _product_list = false;
    _purchase = false;
    _purchase_add = false;
    _purchase_list = false;
    _invoice = false;
    _invoice_add = false;
    _invoice_list = false;
    _invoice_pos = false;
    _returnss = false;
    _return_add = false;
    _return_supplier_list = false;
    _return_invoice_list = false;
    _return_wastage_list = false;
    _stock = false;
    _stock_report = false;
    _stock_report_batch = false;
    _stock_available = false;
    _account = false;
    _account_add_account = false;
    _account_list = false;
    _account_supplier_payment = false;
    _account_customer_receives = false;
    _account_selftransaction = false;
    _account_selftransactionlist = false;
    _account_report = false;
    _report = false;
    _report_add_closing = false;
    _report_closing_list = false;
    _report_sales = false;
    _report_sales_user = false;
    _report_sales_category = false;
    _report_sales_products = false;
    _report_purchase = false;
    _report_purchase_category = false;
    _search = false;
    _search_product = false;
    _search_invoice = false;
    _search_purchase = false;
    _human_resource = false;
    _human_resource_employee = false;
    _human_resource_attendance = false;
    _human_resource_payroll = false;
    _human_resource_expense = false;
    _hr_employee_add_designation = false;
    _hr_employee_designation_list = false;
    _hr_employee_add_employee = false;
    _hr_employee_employee_list = false;
    _hr_attendance_add_attendace = false;
    _hr_attendance_attendance_list = false;
    _hr_attendance_datewise_attendance = false;
    _hr_payroll_add_benefit = false;
    _hr_payroll_benefit_list = false;
    _hr_payroll_add_salary_setup = false;
    _hr_payroll_salary_setup_list = false;
    _hr_payroll_salary_generate = false;
    _hr_payroll_salary_sheet = false;
    _hr_payroll_salary_payment = false;
    _hr_expense_add_expense_item = false;
    _hr_expense_expense_item_list = false;
    _hr_expense_add_expense = false;
    _hr_expense_expense_list = false;
    _hr_expense_expense_satement = false;
  }

  get report_purchase_supplier => _report_purchase_supplier;

  set report_purchase_supplier(value) {
    _report_purchase_supplier = value;
  }

  get human_resource_add_lendingperson => _human_resource_add_lendingperson;

  set human_resource_add_lendingperson(value) {
    _human_resource_add_lendingperson = value;
  }

  get human_resource_lending => _human_resource_lending;

  set human_resource_lending(value) {
    _human_resource_lending = value;
  }

  get transactions => _transactions;

  set transactions(value) {
    _transactions = value;
  }

  get account_add_account => _account_add_account;

  set account_add_account(value) {
    _account_add_account = value;
  }

  get customer => _customer;

  set customer(value) {
    _customer = value;
  }

  get customer_add => _customer_add;

  set customer_add(value) {
    _customer_add = value;
  }

  get customer_list => _customer_list;

  set customer_list(value) {
    _customer_list = value;
  }

  get customer_paid => _customer_paid;

  set customer_paid(value) {
    _customer_paid = value;
  }

  get customer_ledger => _customer_ledger;

  set customer_ledger(value) {
    _customer_ledger = value;
  }

  get customer_credit => _customer_credit;

  set customer_credit(value) {
    _customer_credit = value;
  }

  get supplier => _supplier;

  set supplier(value) {
    _supplier = value;
  }

  get supplier_add => _supplier_add;

  set supplier_add(value) {
    _supplier_add = value;
  }

  get supplier_list => _supplier_list;

  set supplier_list(value) {
    _supplier_list = value;
  }

  get supplier_ledger => _supplier_ledger;

  set supplier_ledger(value) {
    _supplier_ledger = value;
  }

  get product => _product;

  set product(value) {
    _product = value;
  }

  get category_add => _category_add;

  set category_add(value) {
    _category_add = value;
  }

  get category_list => _category_list;

  set category_list(value) {
    _category_list = value;
  }

  get unit_add => _unit_add;

  set unit_add(value) {
    _unit_add = value;
  }

  get unit_list => _unit_list;

  set unit_list(value) {
    _unit_list = value;
  }

  get brand_add => _brand_add;

  set brand_add(value) {
    _brand_add = value;
  }

  get brand_list => _brand_list;

  set brand_list(value) {
    _brand_list = value;
  }

  get product_add => _product_add;

  set product_add(value) {
    _product_add = value;
  }

  get product_list => _product_list;

  set product_list(value) {
    _product_list = value;
  }

  get purchase => _purchase;

  set purchase(value) {
    _purchase = value;
  }

  get purchase_add => _purchase_add;

  set purchase_add(value) {
    _purchase_add = value;
  }

  get purchase_list => _purchase_list;

  set purchase_list(value) {
    _purchase_list = value;
  }

  get invoice => _invoice;

  set invoice(value) {
    _invoice = value;
  }

  get invoice_add => _invoice_add;

  set invoice_add(value) {
    _invoice_add = value;
  }

  get invoice_list => _invoice_list;

  set invoice_list(value) {
    _invoice_list = value;
  }

  get invoice_pos => _invoice_pos;

  set invoice_pos(value) {
    _invoice_pos = value;
  }

  get returnss => _returnss;

  set returnss(value) {
    _returnss = value;
  }

  get return_add => _return_add;

  set return_add(value) {
    _return_add = value;
  }

  get return_supplier_list => _return_supplier_list;

  set return_supplier_list(value) {
    _return_supplier_list = value;
  }

  get return_invoice_list => _return_invoice_list;

  set return_invoice_list(value) {
    _return_invoice_list = value;
  }

  get return_wastage_list => _return_wastage_list;

  set return_wastage_list(value) {
    _return_wastage_list = value;
  }

  get stock => _stock;

  set stock(value) {
    _stock = value;
  }

  get stock_report => _stock_report;

  set stock_report(value) {
    _stock_report = value;
  }

  get stock_report_batch => _stock_report_batch;

  set stock_report_batch(value) {
    _stock_report_batch = value;
  }

  get stock_available => _stock_available;

  set stock_available(value) {
    _stock_available = value;
  }

  get account => _account;

  set account(value) {
    _account = value;
  }

  get account_supplier_payment => _account_supplier_payment;

  set account_supplier_payment(value) {
    _account_supplier_payment = value;
  }

  get account_customer_receives => _account_customer_receives;

  set account_customer_receives(value) {
    _account_customer_receives = value;
  }

  get account_selftransaction => _account_selftransaction;

  set account_selftransaction(value) {
    _account_selftransaction = value;
  }

  get account_report => _account_report;

  set account_report(value) {
    _account_report = value;
  }

  get report => _report;

  set report(value) {
    _report = value;
  }

  get report_add_closing => _report_add_closing;

  set report_add_closing(value) {
    _report_add_closing = value;
  }

  get report_closing_list => _report_closing_list;

  set report_closing_list(value) {
    _report_closing_list = value;
  }

  get report_sales => _report_sales;

  set report_sales(value) {
    _report_sales = value;
  }

  get report_sales_user => _report_sales_user;

  set report_sales_user(value) {
    _report_sales_user = value;
  }

  get report_sales_category => _report_sales_category;

  set report_sales_category(value) {
    _report_sales_category = value;
  }

  get report_sales_products => _report_sales_products;

  set report_sales_products(value) {
    _report_sales_products = value;
  }

  get report_purchase => _report_purchase;

  set report_purchase(value) {
    _report_purchase = value;
  }

  get report_purchase_category => _report_purchase_category;

  set report_purchase_category(value) {
    _report_purchase_category = value;
  }

  get search => _search;

  set search(value) {
    _search = value;
  }

  get search_product => _search_product;

  set search_product(value) {
    _search_product = value;
  }

  get search_invoice => _search_invoice;

  set search_invoice(value) {
    _search_invoice = value;
  }

  get search_purchase => _search_purchase;

  set search_purchase(value) {
    _search_purchase = value;
  }

  get human_resource => _human_resource;

  set human_resource(value) {
    _human_resource = value;
  }

  get human_resource_employee => _human_resource_employee;

  set human_resource_employee(value) {
    _human_resource_employee = value;
  }

  get human_resource_attendance => _human_resource_attendance;

  set human_resource_attendance(value) {
    _human_resource_attendance = value;
  }

  get human_resource_payroll => _human_resource_payroll;

  set human_resource_payroll(value) {
    _human_resource_payroll = value;
  }

  get human_resource_expense => _human_resource_expense;

  set human_resource_expense(value) {
    _human_resource_expense = value;
  }

  get hr_employee_add_designation => _hr_employee_add_designation;

  set hr_employee_add_designation(value) {
    _hr_employee_add_designation = value;
  }

  get hr_employee_designation_list => _hr_employee_designation_list;

  set hr_employee_designation_list(value) {
    _hr_employee_designation_list = value;
  }

  get hr_employee_add_employee => _hr_employee_add_employee;

  set hr_employee_add_employee(value) {
    _hr_employee_add_employee = value;
  }

  get hr_employee_employee_list => _hr_employee_employee_list;

  set hr_employee_employee_list(value) {
    _hr_employee_employee_list = value;
  }

  get hr_attendance_add_attendace => _hr_attendance_add_attendace;

  set hr_attendance_add_attendace(value) {
    _hr_attendance_add_attendace = value;
  }

  get hr_attendance_attendance_list => _hr_attendance_attendance_list;

  set hr_attendance_attendance_list(value) {
    _hr_attendance_attendance_list = value;
  }

  get hr_attendance_datewise_attendance => _hr_attendance_datewise_attendance;

  set hr_attendance_datewise_attendance(value) {
    _hr_attendance_datewise_attendance = value;
  }

  get hr_payroll_add_benefit => _hr_payroll_add_benefit;

  set hr_payroll_add_benefit(value) {
    _hr_payroll_add_benefit = value;
  }

  get hr_payroll_benefit_list => _hr_payroll_benefit_list;

  set hr_payroll_benefit_list(value) {
    _hr_payroll_benefit_list = value;
  }

  get hr_payroll_add_salary_setup => _hr_payroll_add_salary_setup;

  set hr_payroll_add_salary_setup(value) {
    _hr_payroll_add_salary_setup = value;
  }

  get hr_payroll_salary_setup_list => _hr_payroll_salary_setup_list;

  set hr_payroll_salary_setup_list(value) {
    _hr_payroll_salary_setup_list = value;
  }

  get hr_payroll_salary_generate => _hr_payroll_salary_generate;

  set hr_payroll_salary_generate(value) {
    _hr_payroll_salary_generate = value;
  }

  get hr_payroll_salary_sheet => _hr_payroll_salary_sheet;

  set hr_payroll_salary_sheet(value) {
    _hr_payroll_salary_sheet = value;
  }

  get hr_payroll_salary_payment => _hr_payroll_salary_payment;

  set hr_payroll_salary_payment(value) {
    _hr_payroll_salary_payment = value;
  }

  get hr_expense_add_expense_item => _hr_expense_add_expense_item;

  set hr_expense_add_expense_item(value) {
    _hr_expense_add_expense_item = value;
  }

  get hr_expense_expense_item_list => _hr_expense_expense_item_list;

  set hr_expense_expense_item_list(value) {
    _hr_expense_expense_item_list = value;
  }

  get hr_expense_add_expense => _hr_expense_add_expense;

  set hr_expense_add_expense(value) {
    _hr_expense_add_expense = value;
  }

  get hr_expense_expense_list => _hr_expense_expense_list;

  set hr_expense_expense_list(value) {
    _hr_expense_expense_list = value;
  }

  get hr_expense_expense_satement => _hr_expense_expense_satement;

  set hr_expense_expense_satement(value) {
    _hr_expense_expense_satement = value;
  }

  get account_list => _account_list;

  set account_list(value) {
    _account_list = value;
  }

  get human_resource_add_lending => _human_resource_add_lending;

  set human_resource_add_lending(value) {
    _human_resource_add_lending = value;
  }

  get human_resource_lendinglist => _human_resource_lendinglist;

  set human_resource_lendinglist(value) {
    _human_resource_lendinglist = value;
  }

  get human_resource_lendingpersonlist => _human_resource_lendingpersonlist;

  set human_resource_lendingpersonlist(value) {
    _human_resource_lendingpersonlist = value;
  }

  get human_resource_personledger => _human_resource_personledger;

  set human_resource_personledger(value) {
    _human_resource_personledger = value;
  }

  get management_add_user => _management_add_user;

  set management_add_user(value) {
    _management_add_user = value;
  }

  get management_user_list => _management_user_list;

  set management_user_list(value) {
    _management_user_list = value;
  }

  get account_selftransactionlist => _account_selftransactionlist;

  set account_selftransactionlist(value) {
    _account_selftransactionlist = value;
  }

  get account_customer_cheque => _account_customer_cheque;

  set account_customer_cheque(value) {
    _account_customer_cheque = value;
  }

  get account_cheque_list => _account_cheque_list;

  set account_cheque_list(value) {
    _account_cheque_list = value;
  }
}
