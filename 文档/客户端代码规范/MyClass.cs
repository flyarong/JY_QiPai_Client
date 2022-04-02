/*
Code

类, 方法, 枚举, public 字段, public 属性, 命名空间的命名规则用: PascalCase.
局部变量，函数参数命名规则用: camelCase.
private, protected, internal and protected internal 字段和属性的命名规则用: _camelCase.
命名规则不受const, static, readonly等修饰符影响.
对于缩写，也按PascalCase 命名，比如 MyRpc而不是MyRPC.
接口以I,开头..


Files

文件和文件夹 命名规则为PascalCase, 例如 MyFile.cs.
文件名尽量和文件中主要的类名一直, 例如 MyClass.cs.
通常，一个文件中一个类.
 

Organization

如果出现，修饰符按下列顺序书写: public protected internal private new abstract virtual override sealed static readonly extern unsafe volatile async.
命名空间在最顶部，using顺序按Sytem，Unity，自定义的命名空间以及字母顺序排序，
类成员的顺序:
Group按下列顺序:
Nested classes, enums, delegates and events.
Static, const and readonly fields.
Fields and properties.
Constructors and finalizers.
Methods.
每个Group内，按下列顺序:
Public.
Internal.
Protected internal.
Protected.
Private.
*/

using System;                                           //using写在整个文件最前，多个using按下面层级以及字母排序
using System.Collections;                               //1.system提供的
using System.Collections.Generic;
using UnityEngine;                                      //2.unity提供的
using UnityEngine.UI;
using GameDataModule;                                   //3.自定义的namespace
 
namespace MyNamespace 								    // Namespaces 命名规则为 PascalCase.  
{      
	public interface IMyInterface                       // Interfaces 以 'I' 开头
	{          
		public int Calculate(float value, float exp);   // 方法函数 命名规则为 PascalCase 
	}
 
	public enum MyEnum                                  // Enumerations 命名规则为 PascalCase.
	{                                  
		Yes = 0,                                        // Enumerations 命名规则为 PascalCase，并显示标注对应值
		No = 1,
	}
 
	public class MyClass 								// classes 命名规则为 PascalCase.
	{                          
		public int Foo = 0;                             // Public 公有成员变量命名规则为 PascalCase.
		public bool NoCounting = false;                 // 最好对变量初始化.
		private class Results 
		{
			public int NumNegativeResults = 0;
			public int NumPositiveResults = 0;
		}
		private Results _results;                       // Private 私有成员变量命名规则为 _camelCase.
		public static int NumTimesCalled = 0;
		private const int _bar = 100;                   // const 不影响命名规则.
		private int[] _someTable =                  
		{       
			2, 3, 4,                 
		};
		public MyClass()                                // 构造函数命名规则为 PascalCase.
		{
			_results = new Results                      // 对象初始化器最好用换行的方式赋值.
			{
				NumNegativeResults = 1,                 // 操作符前后用个空格分割.  
				NumPositiveResults = 1,           
			};
		}
 
		public int CalculateValue(int mulNumber) 
		{      
			var resultValue = Foo * mulNumber;              // Local variables 局部变量命名规则为camelCase.
			NumTimesCalled++;
			Foo += _bar;
			if (!NoCounting)                                // if后边和括号用个空格分割.
			{                                                                          
				if (resultValue < 0)
				{                                                                  
					_results.NumNegativeResults++;        
				} 
				else if (resultValue > 0)
				{         
					_results.NumPositiveResults++;
				}
			}
			return resultValue;
		}
	
		public void ExpressionBodies() 
		{
		//对于简单的lambda，如果一行能写下，不需要括号
		Func<int, int> increment = x => x + 1;
	
		// 对于复杂一些的lambda，多行书写.
		Func<int, int, long> difference1 = (x, y) => 
		{
			long diff = (long)x - y;
			return diff >= 0 ? diff : -diff;
		};
		}
	
		void DoNothing() {}                             // Empty blocks may be concise.
	
		
		void CallingLongFunctionName() 
		{
		int veryLongArgumentName = 1234;
		int shortArg = 1;
		// 函数调用参数之间用空格分隔
		AnotherLongFunctionNameThatCausesLineWrappingProblems(shortArg, shortArg, veryLongArgumentName);
		// 如果一行写不下可以另起一行，与第一个参数对齐
		AnotherLongFunctionNameThatCausesLineWrappingProblems(veryLongArgumentName, 
																veryLongArgumentName, veryLongArgumentName);
		}
  }
}