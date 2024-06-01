import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:groceyfi02/constants/style.dart';
import 'package:groceyfi02/pages/404/error.dart';
import 'package:get/get.dart';
import 'package:groceyfi02/pages/accounts/cheque_transaction_list.dart';
import 'package:groceyfi02/pages/accounts/customer_cheque.dart';
import 'package:groceyfi02/pages/accounts/customer_receives.dart';
import 'package:groceyfi02/pages/accounts/edit_account.dart';
import 'package:groceyfi02/pages/accounts/supplier_cheque.dart';
import 'package:groceyfi02/pages/accounts/supplier_payment.dart';
import 'package:groceyfi02/pages/accounts/payment_list.dart';
import 'package:groceyfi02/pages/accounts/self_transaction.dart';
import 'package:groceyfi02/pages/accounts/self_transaction_list.dart';
import 'package:groceyfi02/pages/accounts/transactions.dart';
import 'package:groceyfi02/pages/authentication/authentication.dart';
import 'package:groceyfi02/pages/customers/add_customers.dart';
import 'package:groceyfi02/pages/customers/customer_credit.dart';
import 'package:groceyfi02/pages/customers/customer_list.dart';
import 'package:groceyfi02/pages/accounts/accounts_list.dart';
import 'package:groceyfi02/pages/accounts/add_account.dart';
import 'package:groceyfi02/pages/customers/customer_ledger.dart';
import 'package:groceyfi02/pages/customers/edit_customer.dart';
import 'package:groceyfi02/pages/customers/paid_customer.dart';
import 'package:groceyfi02/pages/human_resource/attendance/add_attendance.dart';
import 'package:groceyfi02/pages/human_resource/attendance/attendance_list.dart';
import 'package:groceyfi02/pages/human_resource/attendance/attendance_list_datewise.dart';
import 'package:groceyfi02/pages/human_resource/employee/add_designation.dart';
import 'package:groceyfi02/pages/human_resource/employee/add_employee.dart';
import 'package:groceyfi02/pages/human_resource/employee/designation_list.dart';
import 'package:groceyfi02/pages/human_resource/employee/empoyee_list.dart';
import 'package:groceyfi02/pages/human_resource/expense/add_expense.dart';
import 'package:groceyfi02/pages/human_resource/expense/add_expense_item.dart';
import 'package:groceyfi02/pages/human_resource/expense/expense_item_list.dart';
import 'package:groceyfi02/pages/human_resource/expense/expense_list.dart';
import 'package:groceyfi02/pages/human_resource/expense/expense_satement.dart';
import 'package:groceyfi02/pages/human_resource/lending/add_loan.dart';
import 'package:groceyfi02/pages/human_resource/lending/add_loan_person.dart';
import 'package:groceyfi02/pages/human_resource/lending/loan_person_ledger.dart';
import 'package:groceyfi02/pages/human_resource/lending/loan_person_list.dart';
import 'package:groceyfi02/pages/human_resource/lending/loans_list.dart';
import 'package:groceyfi02/pages/human_resource/payroll/add_benefit.dart';
import 'package:groceyfi02/pages/human_resource/payroll/add_salary_setup.dart';
import 'package:groceyfi02/pages/human_resource/payroll/benefit_list.dart';
import 'package:groceyfi02/pages/human_resource/payroll/salary_setup_list.dart';
import 'package:groceyfi02/pages/invoice/add_invoice.dart';
import 'package:groceyfi02/pages/invoice/invoice_list.dart';
import 'package:groceyfi02/pages/invoice/pos_invoice.dart';
import 'package:groceyfi02/pages/product/edit_Brand.dart';
import 'package:groceyfi02/pages/product/edit_Category.dart';
import 'package:groceyfi02/pages/product/edit_Product.dart';
import 'package:groceyfi02/pages/product/edit_Unit.dart';
import 'package:groceyfi02/pages/return/return_wastage.dart';
import 'package:groceyfi02/pages/return/trash_items_list.dart';
import 'package:groceyfi02/pages/supplier/add_supplier.dart';
import 'package:groceyfi02/pages/supplier/edit_supplier.dart';
import 'package:groceyfi02/pages/supplier/supplier_ledger.dart';
import 'package:groceyfi02/pages/product/category_list.dart';
import 'package:groceyfi02/pages/product/product_list.dart';
import 'package:groceyfi02/pages/product/brand_list.dart';
import 'package:groceyfi02/pages/product/unit_list.dart';
import 'package:groceyfi02/pages/notifications/expire_medi_report.dart';
import 'package:groceyfi02/pages/notifications/stock_out_report.dart';
import 'package:groceyfi02/pages/purchase/add_purchase.dart';
import 'package:groceyfi02/pages/purchase/purchase_list.dart';
import 'package:groceyfi02/pages/reports/add_closing.dart';
import 'package:groceyfi02/pages/reports/closing_list.dart';
import 'package:groceyfi02/pages/reports/invoice_report.dart';
import 'package:groceyfi02/pages/reports/invoice_report_category.dart';
import 'package:groceyfi02/pages/reports/invoice_report_product.dart';
import 'package:groceyfi02/pages/reports/invoice_report_user.dart';
import 'package:groceyfi02/pages/reports/purchase_report.dart';
import 'package:groceyfi02/pages/reports/purchase_report_category.dart';
import 'package:groceyfi02/pages/reports/purchase_report_user.dart';
import 'package:groceyfi02/pages/return/add_return.dart';
import 'package:groceyfi02/pages/return/invoice_return_list.dart';
import 'package:groceyfi02/pages/return/supplier_return_list.dart';
import 'package:groceyfi02/pages/return/wastage_return_list.dart';
import 'package:groceyfi02/pages/roles/add_role.dart';
import 'package:groceyfi02/pages/roles/my_profile.dart';
import 'package:groceyfi02/pages/roles/roles_list.dart';
import 'package:groceyfi02/pages/stock/available_stock.dart';
import 'package:groceyfi02/pages/stock/stock_report.dart';
import 'package:groceyfi02/pages/supplier/supplier_list.dart';
import 'package:groceyfi02/pages/product/add_category.dart';
import 'package:groceyfi02/pages/product/add_product.dart';
import 'package:groceyfi02/pages/product/add_brand.dart';
import 'package:groceyfi02/pages/product/add_unit.dart';
import 'package:groceyfi02/pages/overview/overview.dart';

import 'helpers/MyCustomScrollBehavior.dart';
import 'helpers/app_bar_controller.dart';
import 'helpers/auth_middleware.dart';
import 'helpers/auth_service.dart';
import 'model/nav_bools.dart';
import 'routing/routes.dart';

Future<void> main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyCNc_biypcXrpuA9CUipSZlC2vF7piIGO4",
        authDomain: "groceyfi---02.firebaseapp.com",
        projectId: "groceyfi---02",
        storageBucket: "groceyfi---02.appspot.com",
        messagingSenderId: "312790918896",
        appId: "1:312790918896:web:5ba97352d32ed32ba98435"),
  );
  await Get.put(AuthService());
  final authService = AuthService.to;
  await authService.loadAuthenticationStatus();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Navbools nn = Navbools();
  var pageroute = dashboardPageRoute;
  final AppBarController appController = Get.put(AppBarController());
  @override
  void initState() {
    super.initState();
    appController.fetchData();
  }
  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
      scrollBehavior: MyCustomScrollBehavior(),
      unknownRoute: GetPage(
          name: '/not-found',
          page: () => PageNotFound(),
          transition: Transition.fadeIn),
      defaultTransition: Transition.fadeIn,
      getPages: [
        GetPage(
          name: authenticationPageRoute,
          page: () => AuthenticationPage(),
        ),
        GetPage(
            name: dashboardPageRoute,
            page: () => OverviewPage(
                  nn: nn,
                ),
            middlewares: [AuthMiddleware()]),
        GetPage(
            name: supplierpayment,
            page: () => SupplierPayment(
                  nn: nn,
                ),
            middlewares: [AuthMiddleware()]),
        GetPage(
            name: selftransaction,
            page: () => SelfTransaction(
                  nn: nn,
                ),
            middlewares: [AuthMiddleware()]),
        GetPage(
            name: customerpayment,
            page: () => CustomerReceives(
                  nn: nn,
                ),
            middlewares: [AuthMiddleware()]),
        GetPage(
            name: selftransactionslist,
            page: () => SelfTransactionList(
                  nn: nn,
                ),
            middlewares: [AuthMiddleware()]),
        GetPage(
            name: paymentreport,
            page: () => PaymentList(
                  nn: nn,
                ),
            middlewares: [AuthMiddleware()]),
        GetPage(
            name: customerlistPageRoute,
            page: () => CustomerList(
                  nn: nn,
                ),
            middlewares: [AuthMiddleware()]),
        GetPage(
            name: editcustomerPageRoute,
            page: () => EditCustomer(),
            middlewares: [AuthMiddleware()]),
        GetPage(
            name: editaccount,
            page: () => EditAccount(),
            middlewares: [AuthMiddleware()]),
        GetPage(
            name: editproductPageRoute,
            page: () => EditProduct(),
            middlewares: [AuthMiddleware()]),
        GetPage(
            name: suppliereditPageRoute,
            page: () => EditSupplier(),
            middlewares: [AuthMiddleware()]),
        GetPage(
            name: editcategoryPageRoute,
            page: () => EditCategory(),
            middlewares: [AuthMiddleware()]),
        GetPage(
            name: editbrandPageRoute,
            page: () => EditBrand(),
            middlewares: [AuthMiddleware()]),
        GetPage(
            name: editunitPageRoute,
            page: () => EditUnit(),
            middlewares: [AuthMiddleware()]),
        GetPage(
            name: myprofilePageRoute,
            page: () => MyProfile(),
            middlewares: [AuthMiddleware()]),
        GetPage(
            name: customercreditPageRoute,
            page: () => CustomerCredit(
                  nn: nn,
                ),
            middlewares: [AuthMiddleware()]),
        GetPage(
            name: customerpaidPageRoute,
            page: () => CustomerPaid(
                  nn: nn,

                ),
            middlewares: [AuthMiddleware()]),
        GetPage(
            name: customerledgerPageRoute,
            page: () => CustomerLedger(
                  nn: nn,

                ),
            middlewares: [AuthMiddleware()]),
        GetPage(
            name: addcustomerPageRoute,
            page: () => AddCustomer(
                  nn: nn,
                ),
            middlewares: [AuthMiddleware()]),
        GetPage(
            name: addsupplierPageRoute,
            page: () => AddSupplier(
                  nn: nn,
                ),
            middlewares: [AuthMiddleware()]),
        GetPage(
            name: supplierlistPageRoute,
            page: () => SupplierList(
                  nn: nn,

                ),
            middlewares: [AuthMiddleware()]),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: supplierledgerPageRoute,
          page: () => SupplierLedger(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: addcategoryPageRoute,
          page: () => AddCategory(
            nn: nn,
          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: categorylistPageRoute,
          page: () => CategoryList(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: addproductPageRoute,
          page: () => AddProduct(
            nn: nn,
          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: productlistPageRoute,
          page: () => ProductList(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: addbrandPageRoute,
          page: () => AddBrand(
            nn: nn,
          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: brandlistPageRoute,
          page: () => BrandList(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: addunitPageRoute,
          page: () => AddUnit(
            nn: nn,
          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: unitlistPageRoute,
          page: () => UnitList(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: addpurchasePageRoute,
          page: () => AddPurchase(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: addsalarysetupPageRoute,
          page: () => AddSalarySetup(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: salarysetuplistPageRoute,
          page: () => SalarySetupList(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: benefitlistPageRoute,
          page: () => BenefitList(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: addclosingPageRoute,
          page: () => AddClosing(
            nn: nn,
          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: closinglistPageRoute,
          page: () => ClosingList(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: invoicereportPageRoute,
          page: () => InvoiceReport(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: invoicereportuserPageRoute,
          page: () => InvoiceReportUser(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: invoicereportproductPageRoute,
          page: () => InvoiceReportProduct(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: invoicereportcategoryPageRoute,
          page: () => InvoiceReportCategory(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: purchasereportPageRoute,
          page: () => PurchaseReport(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: stockoutreportPageRoute,
          page: () => StockOutReport(),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: expireproductPageRoute,
          page: () => ExpireMediReport(),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: purchasereportsupplierPageRoute,
          page: () => PurchaseReportUser(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: purchasereportcategoryPageRoute,
          page: () => PurchaseReportCategory(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: stockreportPageRoute,
          page: () => StockReport(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: availablestockPageRoute,
          page: () => AvailableStock(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: addreturnPageRoute,
          page: () => AddReturn(
            nn: nn,
          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: supplierreturnlistPageRoute,
          page: () => ManufactuerReturnList(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: invoicereturnlistPageRoute,
          page: () => InvoiceReturnList(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: wasteagereturnlistPageRoute,
          page: () => WastageReturnList(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: returnwasteagePageRoute,
          page: () => ReturnWastage(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: trashbinPageRoute,
          page: () => TrashItemsList(
            nn: nn,
          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: addaccount,
          page: () => AddAccount(
            nn: nn,
          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: suppliercheque,
          page: () => SupplierChequePayment(
            nn: nn,
          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: customercheque,
          page: () => CustomerChequeReceive(
            nn: nn,
          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: chequelist,
          page: () => ChequeTransactionList(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: accountlist,
          page: () => AccountsList(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: transactions,
          page: () => Transactionsss(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: purchaselistPageRoute,
          page: () => PurchaseList(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: addhrdesignationPageRoute,
          page: () => AddDesignation(
            nn: nn,
          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: addhremployeePageRoute,
          page: () => AddEmployee(
            nn: nn,
          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: designationlistPageRoute,
          page: () => DesignationList(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: employeelistPageRoute,
          page: () => EmployeeList(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: addhraddattendacePageRoute,
          page: () => AddAttendance(
            nn: nn,
          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: attendacelistPageRoute,
          page: () => AttendanceList(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: attendacelistdatewisePageRoute,
          page: () => AttendanceListDateWise(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: addinvoicePageRoute,
          page: () => AddInvoice(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: invoicelistPageRoute,
          page: () => InvoiceList(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: posinvoicePageRoute,
          page: () => PosInvoice(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: purchaselistPageRoute,
          page: () => PurchaseList(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: addexpensePageRoute,
          page: () => AddExpense(
            nn: nn,
          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: addlendingpersonPageRoute,
          page: () => AddLendingPerson(
            nn: nn,
          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: addlendingPageRoute,
          page: () => AddLending(
            nn: nn,
          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: lendingpersonlistPageRoute,
          page: () => LendingPersonList(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: lendinglistPageRoute,
          page: () => LendingList(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: personledgerPageRoute,
          page: () => LendingPersonLedger(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: addexpenseitemPageRoute,
          page: () => AddExpenseItem(
            nn: nn,
          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: expenseitemlistPageRoute,
          page: () => ExpenseItemList(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: expenselistPageRoute,
          page: () => ExpenseList(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: expensestatementPageRoute,
          page: () => ExpenseStatement(
            nn: nn,

          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: addbenefitPageRoute,
          page: () => AddBenefit(
            nn: nn,
          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: addnewuserPageRoute,
          page: () => AddUser(
            nn: nn,
          ),
        ),
        GetPage(
          middlewares: [AuthMiddleware()],
          name: userlistPageRoute,
          page: () => UserList(
            nn: nn,

          ),
        ),
      ],
      initialRoute: dashboardPageRoute,
      debugShowCheckedModeBanner: false,
      title: 'Dashboard',
      theme: ThemeData(
        scaffoldBackgroundColor: light,
        primarySwatch: Colors.blue,
      ),
      // home: AuthenticationPage(),
    );
  }
}
