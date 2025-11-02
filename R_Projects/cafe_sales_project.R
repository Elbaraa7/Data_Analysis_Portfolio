library(tidyverse)
library(janitor)
library(lubridate)
library(scales)


# Import the data
df <- read.csv("cafe_sales.csv", na.strings = c("", NA))


# Data Cleaning 

# check data
glimpse(df)

# clean column names
df_cleaned <- df |>
  janitor::clean_names()

# Check for duplicates
df_cleaned[duplicated(df_cleaned),]

# identifying invalid data 
invalids <- c("", "ERROR", "UNKNOWN", NA)

# Get the unit price for items
df_cleaned |>
  select(c("item", "price_per_unit")) |>
  filter(!item %in% invalids, !price_per_unit %in% invalids) |>
  distinct()

# clean column names
df_cleaned <- df_cleaned |>
  mutate(
    # Clean unit price column
    price_per_unit = case_when(
      !price_per_unit %in% invalids ~ as.numeric(price_per_unit),
      price_per_unit %in% invalids & item == "Coffee" ~ 2.00,
      price_per_unit %in% invalids & item == "Cake" ~ 3.00,
      price_per_unit %in% invalids & item == "Cookie" ~ 1.00,
      price_per_unit %in% invalids & item == "Salad" ~ 5.00,
      price_per_unit %in% invalids & item == "Smoothie" ~ 4.00,
      price_per_unit %in% invalids & item == "Sandwich" ~ 4.00,
      price_per_unit %in% invalids & item == "Juice" ~ 3.00,
      price_per_unit %in% invalids & item == "Tea" ~ 1.50,
      price_per_unit %in% invalids & item %in% invalids & 
        !total_spent %in% invalids & as.numeric(quantity) != 0 ~ 
        round(as.numeric(total_spent) / as.numeric(quantity), 2)
    ),
    
    # Clean quantity column
    quantity = case_when(
      !quantity %in% invalids ~ as.integer(quantity),
      quantity %in% invalids & !total_spent %in% invalids ~ 
        as.integer(as.numeric(total_spent) / price_per_unit),
      TRUE ~ NA_integer_
    ),
    
    # Clean total spent column
    total_spent = case_when(
      !total_spent %in% invalids ~ as.numeric(total_spent),
      total_spent %in% invalids & 
        !is.na(quantity) ~ 
        round(price_per_unit * quantity, 2),
      TRUE ~ NA_real_
    ),
    
    # Clean item column
    item = case_when(
      !item %in% invalids ~ item,
      item %in% invalids & price_per_unit == 2.00 ~ "Coffee",
      item %in% invalids & price_per_unit == 1.00 ~ "Cookie",
      item %in% invalids & price_per_unit == 1.50 ~ "Tea",
      item %in% invalids & price_per_unit == 5.00 ~ "Salad",
      TRUE ~ "UNKNOWN"
    ),
    
    # Clean payment method column
    payment_method = case_when(
      !payment_method %in% invalids ~ payment_method,
      TRUE ~ "UNKNOWN"
    ),
    
    # Clean location column
    location = case_when(
      !location %in% invalids ~ location,
      TRUE ~ "UNKNOWN"
    ),
    
    # Clean date column
    transaction_date = case_when(
      !transaction_date %in% invalids ~ as.Date(transaction_date),
      TRUE ~ as.Date(NA)
    ),
    
    # Create month and year columns
    month = month(transaction_date), 
    year = year(transaction_date)
  ) |>
  suppressWarnings() 


# EDA 

# Revenue by item
revenue_item <- df_cleaned |>
  select(c("item", "total_spent")) |>
  filter(!item %in% invalids, !total_spent %in% invalids) |>
  group_by(item) |>
  summarise(revenue = sum(total_spent)) |>
  arrange(desc(revenue))

# Revenue by item using Column Chart 
ggplot(revenue_item, aes(x = reorder(item, -revenue) , y = revenue)) +
  geom_col(aes(fill = item), show.legend = FALSE) +
  scale_fill_viridis_d("Item") +
  geom_text(aes(label = dollar(round(revenue, 0))), vjust = 1.5, color = "white", size = 4) +
  labs(
    x = "Item",
    y = "Revenue",
    title = "Revenue By Item"
  ) +
  theme_classic()



# Revenue by month
revenue_trend <- df_cleaned |>
  select(c("month", "total_spent")) |>
  filter(!month %in% invalids, !total_spent %in% invalids) |>
  group_by(month) |>
  summarise(revenue = sum(total_spent)) |>
  arrange(desc(month))

# Monthly trend for revenue using line chart
ggplot(revenue_trend, aes(x = month, y = revenue)) +
  scale_x_continuous(breaks=seq(0 , 12 , by = 1)) +
  scale_y_continuous(limits = c(6000, 8000)) +
  geom_line(
    linetype = 1,
    linewidth = 0.5
  ) +
  geom_point(
    color = "deepskyblue4",
    size = 2
  ) +
  labs(
    y = "Revenue",
    x = "Month",
    title = "Monthly trend revenue"
  ) +
  theme_minimal()



# Month-over-Month Revenue Growth analysis
mom <- df_cleaned |> 
  filter(!month %in% invalids, !total_spent %in% invalids) |>
  group_by(month) |>
  summarise(revenue = sum(total_spent)) |>
  mutate(MoM = (revenue - lag(revenue)) / lag(revenue))

ggplot(mom, aes(x = month, y = replace_na(MoM, 0), fill = replace_na(MoM, 0) > 0)) + 
  geom_col(position = "dodge") +
  scale_x_continuous(breaks=seq(1 , 12 , by = 1)) +
  scale_y_continuous(labels = scales::percent)+
  scale_fill_manual(values = c("FALSE" = "indianred", "TRUE" = "seagreen")) +
  labs(
    y = "Growth (%)",
    x = "Month",
    title = "Month-over-Month Revenue Growth",
    fill = "Growth"
  ) +
  theme_minimal()


# Revenue by location and payment method using bar chart
revenue_loc <- df_cleaned |>
  select(c("payment_method", "location" , "total_spent")) |>
  filter(!payment_method %in% invalids,
         !location %in% invalids,
         !total_spent %in% invalids) |>
  group_by(payment_method, location) |>
  summarise(revenue = sum(total_spent)) |>
  arrange(desc(revenue))

ggplot(revenue_loc, aes(fill=payment_method, y=revenue, x=location)) + 
  geom_bar(position="dodge", stat="identity") +
  scale_fill_viridis_d("Payment Method") +
  coord_flip() +
  labs(
    x = "Location",
    y = "Revenue",
    title = "Revenue By Location and Payment method"
  ) +
  theme_classic()



  