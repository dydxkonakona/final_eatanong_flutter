import 'package:final_eatanong_flutter/screens/add_food.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:final_eatanong_flutter/providers/food_provider.dart';
import 'package:final_eatanong_flutter/screens/nav_bar.dart';

class DietLogScreen extends StatefulWidget {
  @override
  _DietLogScreenState createState() => _DietLogScreenState();
}

class _DietLogScreenState extends State<DietLogScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);

    // Normalize _selectedDay for date comparison
    DateTime normalizedSelectedDay = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final loggedFoods = foodProvider.getIntakesForDay(normalizedSelectedDay); // Get logged foods for the selected day
    
    print('Selected day: $_selectedDay'); // Debugging line to print selected day
    print('Logged foods for the day: ${loggedFoods.length}'); // Debugging line to check the number of logged foods

    // Calculate total macros for the selected day
    final dailyMacros = foodProvider.calculateDailyMacros(normalizedSelectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log'),
      ),
      drawer: NavBar(),
      body: Column(
        children: [
          _buildCalendar(),
          const SizedBox(height: 16),
          _buildLoggedFoods(loggedFoods), // Display logged foods for the selected day
          const SizedBox(height: 16),
          _buildTotalMacros(dailyMacros), // Display total macros for the selected day
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the AddLoggedFoodScreen when the button is pressed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddFood()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      calendarFormat: CalendarFormat.week,
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
        weekendStyle: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.redAccent),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
        selectedDecoration: BoxDecoration(color: const Color.fromARGB(255, 255, 171, 165), shape: BoxShape.circle),
        cellMargin: EdgeInsets.all(6.0),
        defaultTextStyle: TextStyle(fontSize: 16),
        weekendTextStyle: TextStyle(fontSize: 16, color: Colors.redAccent),
      ),
      rowHeight: 45,
    );
  }

  Widget _buildLoggedFoods(List loggedFoods) {
    if (loggedFoods.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('No food logged for this day.'),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: loggedFoods.length,
        itemBuilder: (context, index) {
          final loggedFood = loggedFoods[index];
          return ListTile(
            title: Text(loggedFood.foodItem.name),
            subtitle: Text('Quantity: ${loggedFood.quantity}g | Calories: ${loggedFood.totalCalories}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Delete the logged food
                Provider.of<FoodProvider>(context, listen: false).deleteLoggedFood(index);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalMacros(Map<String, double> dailyMacros) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Macros for the Day', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          Text('Calories: ${dailyMacros['calories']?.toStringAsFixed(1)} kcal'),
          Text('Carbohydrates: ${dailyMacros['carbohydrates']?.toStringAsFixed(1)} g'),
          Text('Protein: ${dailyMacros['protein']?.toStringAsFixed(1)} g'),
          Text('Fat: ${dailyMacros['fat']?.toStringAsFixed(1)} g'),
          Text('Sodium: ${dailyMacros['sodium']?.toStringAsFixed(1)} mg'),
          Text('Cholesterol: ${dailyMacros['cholesterol']?.toStringAsFixed(1)} mg'),
        ],
      ),
    );
  }
}
