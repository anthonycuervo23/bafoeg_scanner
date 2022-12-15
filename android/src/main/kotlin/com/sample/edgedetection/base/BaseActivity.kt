package com.sample.edgedetection.base

import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity

abstract class BaseActivity : AppCompatActivity() {

    protected val TAG = this.javaClass.simpleName

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(provideContentViewId())
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        initPresenter()
        prepare()
    }

    override fun onBackPressed() {
        android.util.Log.d("===>", "onBackPressed: 1234")
        android.util.Log.d("BACK", getFragmentManager().getBackStackEntryCount().toString());
        super.onBackPressed();
    }


    fun showMessage(id: Int) {
        Toast.makeText(this, id, Toast.LENGTH_SHORT).show()
    }

    abstract fun provideContentViewId(): Int

    abstract fun initPresenter()

    abstract fun prepare()
}
