# (WIP) XCTreeLang (XCT) Interpreter

### 一种基于iOS Runtime的脚本语言，支持优雅的调用OC的函数。

![ImageExample1](https://github.com/XCBOSA/XCTreeLang/blob/2e23c0ff7117f5cc717976bd8ea349e924d5379c/GithubImages/Screen-Shot-Example1.png)

这个项目最开始的目的是作为依赖注入的配置文件格式，后续慢慢的加入可执行语句，进而想要做一种脚本语言。

由于是全新的语法，且需要支持OC互操作，所以加了一些专属特性。例如，在JSPatch中，您可能会这么写：
``` js
table.indexPathForRow_inSection(1, 0)
```
但是在XCT中，只需要
``` xct
table.indexPath(row: 1 section: 0)
// XCT会在selector中自动插入with or for or in来调用
```
XCT的目标之一是消灭所有终结符，利用上下文推导语句结束，因此，分号和逗号在这个语言里是完全不存在的TokenType。

## 基本语法
### **1. 定义变量**
```
set a = <Expr>
```
XCT不区分变量初始化和赋值，但每个对单个变量赋值的语句都需要前面有个set。

XCT的类型系统包含基础类型、
变量类型XCTLRuntimeVariableType有：
| 变量类型 | 描述 |
| --- | --- |
| typeVoid | nil or no return value |
| typeObject | a NSObject object |
| typeString | a string |
| typeNumber | We only use double as number type |
| typeBoolean | true or false |
| typeFuncIntrinsic | A native NSBlock object, which can be call in script |
| typeFuncImpl | A paragraph definition statement |
### **2. 条件语句 switch-than**
对于任何判断场景，我们只提供switch-than语句。这是一种特殊且优雅的switch语句，其中的每个than条目（就像其它语言的case条目）允许逻辑重叠。
``` xct
switch <Expr> {
    <ThanStmt1>
    <ThanStmt2>
    ...
}
```
其中，Than语句有equalthan、morethan、lessthan与else，至于用法，就像说话一样。

例如，我们写一个判断版本执行不同函数的代码
``` xct
switch appBundleVersion {
    lessthan 30 { nextthan }
    equalthan 30 {
        initialize_app_with_30()
        // 如果小于等于30，则执行这个函数
    }
    lessthan 60 { nextthan }
    equalthan 60 {
        initialize_app_with_60()
        // 如果小于等于60，则执行这个函数
    }
    else {
        log("Warning: Unknown version")
        initialize_app_with_60()
        // 如果其它，则执行这个函数且警告
    }
}
```
### **3. 循环语句 for-in**
For-In语句遍历的对象必须实现了XCTLEnumerator或XCTLEnumeratorProvider协议。XCTLEnumerator代表迭代器本身，XCTLEnumeratorProvider代表提供迭代器的容器（例如NSArray）。如需要您可通过Category为自定义类实现迭代器。
``` xct
for <loop_variable_name> in <Expr> {
    // Todo: Do somethings
}
```
### **4.函数定义语句**
函数定义的关键词一开始是paragraph，但由于它太长了，且很与众不同，所以也加入了一些常见关键词：func和function。它们实际上都是一个TokenType，没有区别。
``` xct
// 无参数函数定义
paragraph <paragraph_name> {
    <Stmt1>
    <Stmt2>
    ...
}

// 有参数函数定义 abc:_:
paragraph abc(arg1 arg2) {
    ...
}
// 调用：abc(1 2)

// 有标签参数函数定义 abcWithArgLabel1:argLabel2:
paragraph abc(argLabel1:arg1 argLabel2:arg2) {

}
// 调用：abc(argLabel1:1 argLabel2:2)
```
### **5.构造语句**
由于此项目初衷是配置文件，所以对构造实例的语法特殊设计。
``` xct
<class_type> <variable_name> {
    [arg1]
    [arg2]
    ...
} [{
    [LateExpr1]
    [LateExpr2]
    ...
}]

// 第二组大括号可有可无，代表当所有代码执行完时最后执行的内容。
```
如果构造的变量要自动注入到OC代码的实例中，需要使用export语句指定变量需要注入。如果要从OC代码实例中获取成员，则需要使用import语句引入。这两个语句都需要写在文档的开头。
``` xct
import mySomeView
export previewViewController

XCTLViewController previewViewController {
    mySomeView
} {
    .view.backgroundColor = UIColor.cyanColor
}
```